require "rails_helper"

RSpec.describe "Sign in", type: :system do
  it "signs in through the login form" do
    admin = create(:admin, email: "admin@example.com", password: "password")

    visit new_user_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password"
    click_on "Iniciar Sesion"

    expect(page).to have_text("Activos")
  end
end
