require "rails_helper"

RSpec.describe "locations/new", type: :view do
  before(:each) do
    assign(:location, Location.new(
      name: "MyString",
      client: nil
    ))
  end

  xit "renders new location form" do
    render

    assert_select "form[action=?][method=?]", locations_path, "post" do
      assert_select "input[name=?]", "location[name]"

      assert_select "input[name=?]", "location[client_id]"
    end
  end
end
