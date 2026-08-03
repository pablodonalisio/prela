import { Controller } from "@hotwired/stimulus";

const TYPOGRAPHY_PROPERTIES = [
  "font-family",
  "font-size",
  "font-weight",
  "font-style",
  "line-height",
  "letter-spacing",
  "text-transform",
  "text-align",
  "color",
];

function copyComputedTypography(sourceRoot, targetRoot) {
  const sourceNodes = [sourceRoot, ...sourceRoot.querySelectorAll("*")];
  const targetNodes = [targetRoot, ...targetRoot.querySelectorAll("*")];

  if (sourceNodes.length !== targetNodes.length) return;

  targetNodes.forEach((target, index) => {
    const computed = window.getComputedStyle(sourceNodes[index]);
    TYPOGRAPHY_PROPERTIES.forEach((property) => {
      target.style.setProperty(property, computed.getPropertyValue(property));
    });
  });
}

function waitForStylesheet(frame, callback) {
  const link = frame.contentDocument?.querySelector('link[rel="stylesheet"]');
  if (!link || link.sheet) {
    callback();
    return;
  }

  link.addEventListener("load", callback, { once: true });
  link.addEventListener("error", callback, { once: true });
}

function escapeCssString(value) {
  return String(value).replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function reportCodeFooterOverride(report) {
  const code = report.dataset.reportCode;
  if (!code) return "";

  const label = report.dataset.reportFooterLabel || "Informe";
  return `
    @page {
      @bottom-right {
        content: "${escapeCssString(label)}: ${escapeCssString(code)}\\A " "Página " counter(page) " de " counter(pages);
      }
    }
  `;
}

function contactFooterOverride(contactFooter) {
  if (!contactFooter) return "";

  const lines = contactFooter
    .split("\n")
    .map((line) => escapeCssString(line))
    .join("\\A ");

  return `
    @page {
      @bottom-left {
        content: "${lines}";
      }
    }
  `;
}

export default class extends Controller {
  static values = {
    stylesheet: String,
    contactFooter: String,
  };

  print() {
    const report = this.element.querySelector(".template-report");
    if (!report) {
      window.print();
      return;
    }

    const rootFontSize = window.getComputedStyle(document.documentElement).fontSize;
    const printStyles = `
      html { font-size: ${rootFontSize}; }
      ${contactFooterOverride(this.contactFooterValue)}
      ${reportCodeFooterOverride(report)}
    `;

    const frame = document.createElement("iframe");
    frame.setAttribute("aria-hidden", "true");
    frame.style.cssText =
      "position:fixed;width:0;height:0;border:0;opacity:0;pointer-events:none";
    document.body.appendChild(frame);

    const stylesheetHref = this.stylesheetValue;

    frame.srcdoc = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  ${stylesheetHref ? `<link rel="stylesheet" href="${stylesheetHref}">` : ""}
  <style>${printStyles}</style>
</head>
<body class="template-report-print-body"><div class="template-report-print-page">${report.outerHTML}</div></body>
</html>`;

    frame.onload = () => {
      waitForStylesheet(frame, () => {
        const targetReport = frame.contentDocument?.querySelector(".template-report");
        if (targetReport) {
          copyComputedTypography(report, targetReport);
        }

        window.setTimeout(() => {
          frame.contentWindow?.focus();
          frame.contentWindow?.print();
          window.setTimeout(() => frame.remove(), 1000);
        }, 50);
      });
    };
  }
}
