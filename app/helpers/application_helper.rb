module ApplicationHelper
  FLASH_CLASSES = {
    notice: "alert alert-info",
    success: "alert alert-success",
    error: "alert alert-danger",
    alert: "alert alert-danger"
  }.freeze

  def flash_class(level)
    FLASH_CLASSES[level.to_sym]
  end
end
