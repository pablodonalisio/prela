import { Controller } from "@hotwired/stimulus";

// Prints only the label: window.print() from inside the modal would print the
// equipment page behind it as well.
export default class extends Controller {
  static targets = ["label"];
  static values = { stylesheet: String, pageSize: String };

  print() {
    const frame = document.createElement("iframe");
    frame.setAttribute("aria-hidden", "true");
    frame.style.cssText =
      "position:fixed;width:0;height:0;border:0;opacity:0;pointer-events:none";
    document.body.appendChild(frame);

    frame.srcdoc = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <link rel="stylesheet" href="${this.stylesheetValue}">
  <style>
    @page { size: ${this.pageSizeValue}; margin: 0; }
    html, body { margin: 0; padding: 0; }
    [data-qr-label-print-target="label"] { border: 0; }
  </style>
</head>
<body class="bg-white">${this.labelTarget.outerHTML}</body>
</html>`;

    frame.onload = () => {
      const print = () => {
        frame.contentWindow?.focus();
        frame.contentWindow?.print();
        window.setTimeout(() => frame.remove(), 1000);
      };

      const link = frame.contentDocument?.querySelector('link[rel="stylesheet"]');
      if (!link || link.sheet) {
        print();
        return;
      }

      link.addEventListener("load", print, { once: true });
      link.addEventListener("error", print, { once: true });
    };
  }
}
