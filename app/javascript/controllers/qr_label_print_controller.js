import { Controller } from "@hotwired/stimulus";

// Prints only the label: window.print() from inside the modal would print the
// equipment page behind it as well.
export default class extends Controller {
  static targets = ["label"];
  static values = { stylesheets: Array, pageSize: String };

  print() {
    const frame = document.createElement("iframe");
    frame.setAttribute("aria-hidden", "true");
    frame.style.cssText =
      "position:fixed;width:0;height:0;border:0;opacity:0;pointer-events:none";
    document.body.appendChild(frame);

    const links = this.stylesheetsValue
      .map((href) => `<link rel="stylesheet" href="${href}">`)
      .join("\n  ");

    frame.srcdoc = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  ${links}
  <style>
    @page { size: ${this.pageSizeValue}; margin: 0; }
    html, body { margin: 0; padding: 0; }
    [data-qr-label-print-target="label"] { border: 0; }
  </style>
</head>
<body class="bg-white">${this.labelTarget.outerHTML}</body>
</html>`;

    frame.onload = async () => {
      const doc = frame.contentDocument;
      const stylesheets = [...doc.querySelectorAll('link[rel="stylesheet"]')];
      await Promise.all(stylesheets.map(stylesheetLoaded));

      // The icon font only starts downloading once layout needs it.
      doc.body.getBoundingClientRect();
      await doc.fonts?.ready;

      frame.contentWindow?.focus();
      frame.contentWindow?.print();
      window.setTimeout(() => frame.remove(), 1000);
    };
  }
}

function stylesheetLoaded(link) {
  if (link.sheet) return Promise.resolve();

  return new Promise((resolve) => {
    link.addEventListener("load", resolve, { once: true });
    link.addEventListener("error", resolve, { once: true });
  });
}
