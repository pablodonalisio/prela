import { Controller } from "@hotwired/stimulus";

// Shows the layout spinner while a Turbo fetch is in flight.
//
// Hover prefetch uses the same events. Turbo stamps those requests with
// X-Sec-Purpose: prefetch and does not repeat the header on the response, so
// in-flight prefetches are counted by URL and skipped when that URL answers.
//
// A cancelled visit aborts the fetch. Turbo swallows AbortError and never
// fires turbo:fetch-request-error, so the abort signal has to drop the count.
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 200 },
  };

  connect() {
    this.pending = 0;
    this.prefetches = new Map();
    this.requests = [];
    this.showTimer = null;

    this.onRequest = (event) => this.start(event);
    this.onResponse = (event) => this.finishResponse(event);
    this.onError = (event) => this.finishError(event);

    document.addEventListener("turbo:before-fetch-request", this.onRequest);
    document.addEventListener("turbo:before-fetch-response", this.onResponse);
    document.addEventListener("turbo:fetch-request-error", this.onError);
  }

  disconnect() {
    document.removeEventListener("turbo:before-fetch-request", this.onRequest);
    document.removeEventListener("turbo:before-fetch-response", this.onResponse);
    document.removeEventListener("turbo:fetch-request-error", this.onError);
    this.requests.forEach((entry) => this.forget(entry));
    this.requests = [];
    this.clearShowTimer();
    this.hide();
  }

  start(event) {
    const url = this.urlKey(event.detail?.url);

    if (this.isPrefetch(event.detail?.fetchOptions?.headers)) {
      this.prefetches.set(url, (this.prefetches.get(url) || 0) + 1);
      return;
    }

    this.pending += 1;
    this.track(event, url);
    if (this.pending === 1) this.scheduleShow();
  }

  finishResponse(event) {
    this.finish(this.urlKey(event.detail?.fetchResponse?.response?.url));
  }

  finishError(event) {
    const request = event.detail?.request;
    const url = this.urlKey(request?.url);

    if (this.isPrefetch(request?.headers)) {
      this.consumePrefetch(url);
      return;
    }

    this.finish(url);
  }

  finish(url) {
    if (this.consumePrefetch(url)) return;

    this.settle(url);
    this.release();
  }

  track(event, url) {
    const signal = event.detail?.fetchOptions?.signal;
    const entry = { url, signal, settled: false, onAbort: null };

    if (signal) {
      entry.onAbort = () => {
        if (entry.settled) return;

        entry.settled = true;
        this.forget(entry);
        this.release();
      };
      signal.addEventListener("abort", entry.onAbort);
    }

    this.requests.push(entry);
  }

  settle(url) {
    let entry = this.requests.find((item) => !item.settled && item.url === url);
    if (!entry) {
      const open = this.requests.filter((item) => !item.settled);
      if (open.length === 1) entry = open[0];
    }
    if (!entry) return;

    entry.settled = true;
    this.forget(entry);
  }

  forget(entry) {
    if (entry.signal && entry.onAbort) {
      entry.signal.removeEventListener("abort", entry.onAbort);
    }
  }

  release() {
    this.pending = Math.max(0, this.pending - 1);
    if (this.pending > 0) return;

    this.clearShowTimer();
    this.hide();
  }

  scheduleShow() {
    this.clearShowTimer();
    this.showTimer = setTimeout(() => {
      this.showTimer = null;
      if (this.pending === 0) return;

      this.element.classList.remove("hidden");
      this.element.classList.add("flex");
    }, this.delayValue);
  }

  clearShowTimer() {
    if (this.showTimer == null) return;

    clearTimeout(this.showTimer);
    this.showTimer = null;
  }

  hide() {
    this.element.classList.add("hidden");
    this.element.classList.remove("flex");
  }

  consumePrefetch(url) {
    const count = this.prefetches.get(url) || 0;
    if (count === 0) return false;

    if (count === 1) this.prefetches.delete(url);
    else this.prefetches.set(url, count - 1);

    return true;
  }

  isPrefetch(headers) {
    if (!headers) return false;

    const purpose =
      typeof headers.get === "function"
        ? headers.get("X-Sec-Purpose") || headers.get("Sec-Purpose")
        : headers["X-Sec-Purpose"] || headers["Sec-Purpose"];

    return purpose === "prefetch";
  }

  urlKey(url) {
    if (!url) return "";

    try {
      const parsed = url instanceof URL ? new URL(url.href) : new URL(url, window.location.href);
      parsed.hash = "";
      return parsed.href;
    } catch (_error) {
      return String(url);
    }
  }
}
