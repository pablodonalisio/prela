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

  def sidebar_links
    [
      {text: "Mantenimiento", path: location_equipments_path, icon: "fa-wrench"},
      {text: "Clientes", path: clients_path, icon: "fa-building"},
      {text: "Equipos", path: equipment_index_path, icon: "fa-bolt"},
      {text: "Insumos", path: supplies_path, icon: "fa-car-battery"}
    ]
  end

  def image_for(resource, img_attribute, size)
    return "placeholder-img.jpeg" unless resource.send(img_attribute).attached?

    resource.send(img_attribute).variant(resize: size)
  end
end
