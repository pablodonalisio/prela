require "rails_helper"

RSpec.describe "clients/index", type: :view do
  before(:each) do
    assign(:clients, [
      Client.create!(
        name: "Name",
        avatar: nil
      ),
      Client.create!(
        name: "Name",
        avatar: nil
      )
    ])
  end

  it "renders a list of clients" do
    render
    cell_selector = (Rails::VERSION::STRING >= "7") ? "div>p" : "tr>td"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
