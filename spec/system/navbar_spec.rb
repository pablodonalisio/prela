require "rails_helper"

RSpec.describe "Navbar", type: :system do
  let(:admin) { create(:admin) }

  before { login_as(admin, scope: :user) }

  it "signs out from the user menu" do
    visit root_path
    click_on "Abrir menú de usuario"
    click_on "Cerrar Sesión"

    expect(page).to have_text("Iniciar Sesión")
  end
end
