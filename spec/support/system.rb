Capybara.default_max_wait_time = 5
Capybara.enable_aria_label = true

module SystemSpecHelpers
  def use_mobile_layout
    page.current_window.resize_to(390, 844)
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride",
      width: 390,
      height: 844,
      deviceScaleFactor: 1,
      mobile: false
    )
  end

  def use_desktop_layout
    page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride")
    page.current_window.resize_to(1400, 1400)
  end
end

RSpec.configure do |config|
  # System specs drive a browser and are slow. `bundle exec rspec` skips them.
  # `bundle exec rspec spec/system` runs them, and so does RUN_SYSTEM_SPECS=1.
  run_system_specs = ENV["RUN_SYSTEM_SPECS"] == "1" || ARGV.any? { |arg| arg.include?("spec/system") }
  config.filter_run_excluding type: :system unless run_system_specs

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  config.include Warden::Test::Helpers, type: :system
  config.include SystemSpecHelpers, type: :system

  config.before(:each, type: :system) do
    Warden.test_mode!
  end

  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
