import { Controller } from "@hotwired/stimulus"
import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import { TextStyle } from "@tiptap/extension-text-style"
import { Color } from "@tiptap/extension-color"
import FontFamily from "@tiptap/extension-font-family"
import Highlight from "@tiptap/extension-highlight"
import Underline from "@tiptap/extension-underline"
import Link from "@tiptap/extension-link"
import TextAlign from "@tiptap/extension-text-align"

const TextStyleWithSize = TextStyle.extend({
  addAttributes() {
    return {
      ...(this.parent?.() ?? {}),
      fontSize: {
        default: null,
        parseHTML: (element) => element.style.fontSize?.replace(/['"]+/g, "") || null,
        renderHTML: (attributes) => {
          if (!attributes.fontSize) return {}
          return { style: `font-size: ${attributes.fontSize}` }
        }
      }
    }
  }
})

const REMOVED_PASTE_SELECTOR = "img, picture, video, iframe, object, embed, svg, canvas, source, audio"

// Flowbite's WYSIWYG is TipTap plus a toolbar. Image and video extensions are
// left out, and paste/drop of files is rejected, so the field cannot carry
// an upload.
export default class extends Controller {
  static targets = ["input", "editor", "menuButton", "menu", "markButton"]

  connect() {
    this.onSubmit = () => this.syncInput()
    this.form = this.element.closest("form")
    this.form?.addEventListener("submit", this.onSubmit)
    this.dropdowns = this.#bindMenus()

    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [
        StarterKit,
        TextStyleWithSize,
        Color,
        FontFamily,
        Highlight.configure({ multicolor: true }),
        Underline,
        Link.configure({
          openOnClick: false,
          autolink: true,
          linkOnPaste: true,
          defaultProtocol: "https",
          HTMLAttributes: { target: "_blank", rel: "noopener noreferrer" },
          isAllowedUri: (url) => /^(https?:\/\/|mailto:)/i.test(url || "")
        }),
        TextAlign.configure({ types: ["heading", "paragraph"] })
      ],
      content: this.#initialHtml(),
      editorProps: {
        attributes: {
          class: "format dark:format-invert max-w-none focus:outline-none",
          "aria-label": "Texto"
        },
        handlePaste: (_view, event) => this.#rejectImagePaste(event),
        handleDrop: (_view, event) => this.#rejectImageDrop(event),
        transformPastedHTML: (html) => this.#stripEmbeddedMedia(html)
      },
      onUpdate: () => {
        this.syncInput()
        this.#refreshMarks()
      },
      onSelectionUpdate: () => this.#refreshMarks(),
      onBlur: () => {
        this.syncInput()
        this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })

    this.#refreshMarks()
  }

  disconnect() {
    this.form?.removeEventListener("submit", this.onSubmit)
    this.editor?.destroy()
    this.editor = null
    this.dropdowns?.forEach((dropdown) => dropdown.destroyAndRemoveInstance())
    this.dropdowns = []
  }

  bold(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleBold().run()
  }

  italic(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleItalic().run()
  }

  underline(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleUnderline().run()
  }

  strike(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleStrike().run()
  }

  highlight(event) {
    event.preventDefault()
    const active = this.editor.isActive("highlight")
    this.editor.chain().focus().toggleHighlight(active ? undefined : { color: "#ffc078" }).run()
  }

  code(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleCode().run()
  }

  link(event) {
    event.preventDefault()
    const previous = this.editor.getAttributes("link").href || ""
    const url = window.prompt("URL del enlace", previous || "https://")
    if (url === null) return
    if (url.trim() === "") {
      this.editor.chain().focus().unsetLink().run()
      return
    }
    if (!/^(https?:\/\/|mailto:)/i.test(url.trim())) return
    this.editor.chain().focus().extendMarkRange("link").setLink({ href: url.trim() }).run()
  }

  unlink(event) {
    event.preventDefault()
    this.editor.chain().focus().unsetLink().run()
  }

  align(event) {
    event.preventDefault()
    this.editor.chain().focus().setTextAlign(event.currentTarget.dataset.align).run()
  }

  paragraph(event) {
    event.preventDefault()
    this.editor.chain().focus().setParagraph().run()
    this.#hideMenu(event.currentTarget)
  }

  heading(event) {
    event.preventDefault()
    const level = Number(event.currentTarget.dataset.headingLevel)
    this.editor.chain().focus().toggleHeading({ level }).run()
    this.#hideMenu(event.currentTarget)
  }

  textSize(event) {
    event.preventDefault()
    const fontSize = event.currentTarget.dataset.textSize
    const chain = this.editor.chain().focus()
    if (fontSize) {
      chain.setMark("textStyle", { fontSize }).run()
    } else {
      chain.setMark("textStyle", { fontSize: null }).removeEmptyTextStyle().run()
    }
    this.#hideMenu(event.currentTarget)
  }

  fontFamily(event) {
    event.preventDefault()
    const fontFamily = event.currentTarget.dataset.fontFamily
    const chain = this.editor.chain().focus()
    if (fontFamily) {
      chain.setFontFamily(fontFamily).run()
    } else {
      chain.unsetFontFamily().run()
    }
    this.#hideMenu(event.currentTarget)
  }

  pickColor(event) {
    this.editor.chain().focus().setColor(event.currentTarget.value).run()
  }

  setColor(event) {
    event.preventDefault()
    this.editor.chain().focus().setColor(event.currentTarget.dataset.hexColor).run()
    this.#hideMenu(event.currentTarget)
  }

  resetColor(event) {
    event.preventDefault()
    this.editor.chain().focus().unsetColor().run()
    this.#hideMenu(event.currentTarget)
  }

  bulletList(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleBulletList().run()
  }

  orderedList(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleOrderedList().run()
  }

  blockquote(event) {
    event.preventDefault()
    this.editor.chain().focus().toggleBlockquote().run()
  }

  horizontalRule(event) {
    event.preventDefault()
    this.editor.chain().focus().setHorizontalRule().run()
  }

  syncInput() {
    if (!this.editor) return
    this.inputTarget.value = this.#serializedHtml()
  }

  #bindMenus() {
    const Dropdown = window.Dropdown ?? window.Flowbite?.Dropdown
    if (!Dropdown) return []

    return this.menuButtonTargets.map((button) => {
      const menu = this.element.querySelector(`#${button.dataset.menuId}`)
      if (!menu) return null

      const dropdown = new Dropdown(menu, button, { placement: "bottom-start", offsetDistance: 8 })
      dropdown._popperInstance?.setOptions({ strategy: "fixed" })
      return dropdown
    }).filter(Boolean)
  }

  #hideMenu(button) {
    const menu = button.closest("[data-wysiwyg-target~='menu']")
    if (!menu) return

    const dropdown = menu.id ? window.FlowbiteInstances?.getInstance?.("Dropdown", menu.id) : null
    if (dropdown) {
      dropdown.hide()
      return
    }

    menu.classList.add("hidden")
    menu.classList.remove("block")
  }

  #refreshMarks() {
    this.markButtonTargets.forEach((button) => {
      const mark = button.dataset.mark
      const align = button.dataset.align
      const active = align ? this.editor.isActive({ textAlign: align }) : this.editor.isActive(mark)
      button.classList.toggle("bg-neutral-tertiary", active)
      button.classList.toggle("text-heading", active)
    })
  }

  #initialHtml() {
    const stored = this.inputTarget.value
    if (!stored.trim()) return ""
    if (/<\/?[a-z][\s\S]*>/i.test(stored)) return stored

    const escape = (text) => text
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")

    return stored
      .split(/\n{2,}/)
      .map((paragraph) => `<p>${escape(paragraph).replaceAll("\n", "<br>")}</p>`)
      .join("")
  }

  #serializedHtml() {
    const html = this.editor.getHTML()
    const text = this.editor.getText().replaceAll("\u00a0", " ").trim()
    if (!text && !html.includes("<hr")) return ""
    return html
  }

  #rejectImagePaste(event) {
    const data = event.clipboardData
    if (!data) return false

    const images = [...data.files].filter((file) => file.type.startsWith("image/"))
    if (images.length === 0) return false

    const text = data.getData("text/plain").trim()
    const html = this.#stripEmbeddedMedia(data.getData("text/html") || "")
    const htmlText = html.replace(/<[^>]+>/g, "").trim()
    if (text || htmlText) return false

    event.preventDefault()
    return true
  }

  #rejectImageDrop(event) {
    const files = [...(event.dataTransfer?.files || [])]
    if (!files.some((file) => file.type.startsWith("image/"))) return false

    event.preventDefault()
    return true
  }

  #stripEmbeddedMedia(html) {
    if (!html) return html

    const doc = new DOMParser().parseFromString(html, "text/html")
    doc.querySelectorAll(REMOVED_PASTE_SELECTOR).forEach((node) => node.remove())
    doc.querySelectorAll("[style]").forEach((node) => {
      const style = node.getAttribute("style") || ""
      if (/url\s*\(|image-set|expression\s*\(|javascript:/i.test(style)) node.removeAttribute("style")
    })
    return doc.body.innerHTML
  }
}
