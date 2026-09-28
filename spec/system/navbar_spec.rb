require "rails_helper"

RSpec.describe "Navbar", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "signs out from the user menu" do
    visit root_path
    click_on "Menú de usuario"
    click_on "Cerrar Sesion"

    expect(page).to have_text("Iniciar Sesion")
  end
end
