module ApplicationHelper
  include Pagy::Frontend

  # Font Awesome is loaded by the application layout, so #icon renders the same
  # everywhere. Views name icons semantically and never touch Font Awesome
  # classes directly.
  ICON_CLASSES = {
    add: "fa-solid fa-plus",
    agenda: "fa-solid fa-calendar",
    building: "fa-solid fa-building",
    calendar_plus: "fas fa-calendar-plus",
    check: "fas fa-check",
    chevron_down: "fa-solid fa-chevron-down",
    clients: "fa-solid fa-building",
    dot: "fa fa-circle",
    edit: "fas fa-edit",
    envelope: "fa-solid fa-envelope",
    equipment: "fa-solid fa-wrench",
    file: "fa fa-file",
    file_outline: "fa-regular fa-file",
    filter: "fa-solid fa-filter",
    grip: "fa fa-grip-vertical",
    home: "fa-solid fa-house",
    key: "fa-solid fa-key",
    list: "fa fa-list-ul",
    location: "fa-solid fa-location-dot",
    menu: "fa-solid fa-bars",
    note: "fas fa-sticky-note",
    pause: "fas fa-pause",
    plug: "fa fa-plug",
    print: "fa fa-print",
    reports: "fa-solid fa-file-lines",
    settings: "fa fa-sliders-h",
    supplies: "fa-solid fa-car-battery",
    theme_dark: "fa-solid fa-moon",
    theme_light: "fa-solid fa-sun",
    trash: "fas fa-trash",
    undo: "fas fa-undo",
    view: "fas fa-eye",
    whatsapp: "fa-brands fa-whatsapp"
  }.freeze

  # Raises instead of rendering nothing so a typo surfaces in development
  # rather than silently dropping an icon in production.
  def icon(name, **options)
    classes = ICON_CLASSES.fetch(name.to_sym) do
      raise ArgumentError, "Unknown icon #{name.inspect}. Add it to ApplicationHelper::ICON_CLASSES."
    end

    options[:class] = [classes, options[:class]].compact.join(" ")
    options[:aria] = {hidden: true}.merge(options[:aria] || {})

    tag.i(nil, **options)
  end

  FLOWBITE_BUTTON_CLASSES =
    "inline-flex items-center justify-center rounded-lg bg-brand px-5 py-2.5 text-sm font-medium text-white transition-colors hover:bg-brand-strong focus:ring-4 focus:ring-brand-soft".freeze

  FLASH_CLASSES = {
    notice: "alert alert-info",
    success: "alert alert-success",
    error: "alert alert-danger",
    alert: "alert alert-danger"
  }.freeze

  def flash_class(level)
    FLASH_CLASSES[level.to_sym]
  end

  FLOWBITE_FLASH_CLASSES = {
    notice: "border-blue-300 bg-blue-50 text-blue-800 dark:border-blue-800 dark:bg-gray-800 dark:text-blue-400",
    success: "border-green-300 bg-green-50 text-green-800 dark:border-green-800 dark:bg-gray-800 dark:text-green-400",
    error: "border-red-300 bg-red-50 text-red-800 dark:border-red-800 dark:bg-gray-800 dark:text-red-400",
    alert: "border-red-300 bg-red-50 text-red-800 dark:border-red-800 dark:bg-gray-800 dark:text-red-400"
  }.freeze

  def flowbite_flash_classes(level)
    FLOWBITE_FLASH_CLASSES.fetch(level.to_sym, FLOWBITE_FLASH_CLASSES[:notice])
  end

  def nested_dom_id(*args)
    args.map { |arg| arg.respond_to?(:to_key) ? dom_id(arg) : arg }.join("_")
  end

  def active_class(path)
    if request.path == path || request.path.start_with?(path + "/")
      "active"
    else
      ""
    end
  end

  def sidebar_links
    [
      {text: "Home", path: root_path, icon: :home, admin: false},
      {text: "Agenda", path: agenda_index_path, icon: :agenda, admin: false},
      {text: "Activos", path: location_equipments_path, icon: :equipment, admin: false},
      {text: "Informes", path: report_templates_path, icon: :reports, admin: true},
      {text: "Clientes", path: clients_path, icon: :clients, admin: true},
      {text: "Insumos", path: supplies_path, icon: :supplies, admin: true}
    ]
  end

  def image_for(resource, img_attribute, size)
    return "placeholder-img.jpeg" unless resource.send(img_attribute).attached?

    resource.send(img_attribute).variant(resize: size)
  end
end
