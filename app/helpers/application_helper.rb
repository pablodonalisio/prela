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

  def nested_dom_id(*args)
    args.map { |arg| arg.respond_to?(:to_key) ? dom_id(arg) : arg }.join("_")
  end

  def active_class(path)
    if request.path == path
      "active"
    else
      ""
    end
  end
end
