require "rails_helper"

RSpec.describe "clients/show", type: :view do
  before(:each) do
    assign(:client, Client.create!(
      name: "Name",
      avatar: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
