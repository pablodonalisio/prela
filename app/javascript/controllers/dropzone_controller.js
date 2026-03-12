import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

// Dropzone is pinned through importmap.
import Dropzone from "dropzone";

Dropzone.autoDiscover = false;

export default class extends Controller {
  static targets = ["dropzone", "hiddenInputs", "removedInputs"];
  static values = {
    directUploadUrl: String,
    existingFiles: String,
    maxFiles: Number,
    resizeWidth: Number,
    resizeHeight: Number,
    resizeQuality: Number,
  };

  connect() {
    this.initializeDropzone();
    this.loadExistingFiles();
  }

  disconnect() {
    if (this.dropzoneInstance) {
      this.dropzoneInstance.destroy();
      this.dropzoneInstance = null;
    }
  }

  initializeDropzone() {
    if (!this.hasDropzoneTarget) return;

    this.dropzoneInstance = new Dropzone(this.dropzoneTarget, {
      url: "#", // direct upload is done by ActiveStorage, not Dropzone backend.
      autoProcessQueue: false,
      clickable: true,
      maxFiles: this.maxFilesValue || 5,
      acceptedFiles: "image/*",
      addRemoveLinks: true,
      resizeWidth: this.resizeWidthValue,
      resizeHeight: this.resizeHeightValue,
      resizeQuality: this.resizeQualityValue || 0.8,
      thumbnailHeight: 120,
      thumbnailWidth: 120,
    });

    this.dropzoneInstance.on("addedfile", (file) => {
      this.handleAddedFile(file);
    });

    this.dropzoneInstance.on("removedfile", (file) => {
      this.handleRemovedFile(file);
    });
  }

  handleAddedFile(file) {
    if (file.existing) {
      // Already uploaded existing record file; no need for new direct upload.
      return;
    }

    const uploadFile = file.upload?.file || file;
    if (!uploadFile) {
      this.dropzoneInstance.emit("error", file, "Invalid file object");
      return;
    }

    const directUploadUrl =
      this.directUploadUrlValue || "/rails/active_storage/direct_uploads";
    const directUpload = new DirectUpload(uploadFile, directUploadUrl);

    directUpload.create((error, blob) => {
      if (error) {
        this.dropzoneInstance.emit("error", file, error);
        return;
      }

      this.appendHiddenInput(blob.signed_id, file);
      this.dropzoneInstance.emit("success", file, "Upload completed");
      this.dropzoneInstance.emit("complete", file);
    });
  }

  handleRemovedFile(file) {
    const identifier = this.fileIdentifier(file);

    if (file.existing && file.blobId) {
      this.appendRemovedInput(file.blobId, file);
    }

    const existingInput = this.hiddenInputsTarget.querySelector(
      `input[data-dropzone-file-id="${identifier}"]`,
    );
    if (existingInput) existingInput.remove();
  }

  appendHiddenInput(signedId, file) {
    if (!this.hasHiddenInputsTarget) return;

    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "report[images][]";
    input.value = signedId;
    input.dataset.dropzoneFileId = this.fileIdentifier(file);
    this.hiddenInputsTarget.appendChild(input);
  }

  appendRemovedInput(blobId, file) {
    if (!this.hasRemovedInputsTarget) return;

    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "report[removed_image_ids][]";
    input.value = blobId;
    input.dataset.dropzoneFileId = this.fileIdentifier(file);
    this.removedInputsTarget.appendChild(input);
  }

  fileIdentifier(file) {
    return (
      file.upload?.uuid || `${file.name}-${file.size}-${file.lastModified}`
    );
  }

  loadExistingFiles() {
    if (!this.hasDropzoneTarget || !this.hasExistingFilesValue) return;

    let existingFiles = [];
    try {
      existingFiles = JSON.parse(this.existingFilesValue);
    } catch {
      return;
    }

    existingFiles.forEach((file) => {
      const mockFile = {
        name: file.filename,
        size: file.byte_size,
        existing: true,
        blobId: file.id,
      };

      this.dropzoneInstance.emit("addedfile", mockFile);
      this.dropzoneInstance.emit("thumbnail", mockFile, file.url);
      this.dropzoneInstance.emit("complete", mockFile);

      // Keep one extra hidden field for existing items if needed by UI state.
      // Existing attachments are already on the record and do not need a signed_id.
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "report[existing_image_ids][]";
      input.value = file.id;
      input.dataset.dropzoneFileId = this.fileIdentifier(mockFile);
      this.hiddenInputsTarget.appendChild(input);
    });
  }
}
