# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "select_menu_styles"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "dropzone" # @6.0.0
pin "just-extend" # @5.1.1
pin "@rails/activestorage", to: "@rails--activestorage.js" # @8.1.200
pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@4.0.1/dist/flowbite.turbo.min.js"
pin "flowbite-datepicker", to: "https://cdn.jsdelivr.net/npm/flowbite-datepicker@2.0.0/dist/Datepicker.esm.js"
