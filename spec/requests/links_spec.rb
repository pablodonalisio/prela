require 'rails_helper'

RSpec.describe "Links", type: :request do
  let!(:link) { Link.create(title: "Example Link", url: "http://example.com") }

  # Test para mostrar los enlaces de interés en la vista de inicio
  describe "GET /home" do
    it "muestra una lista de enlaces existentes" do
      get "/home/index"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Example Link") # Verifica que el enlace se muestra
    end
  end

  # Test para crear un nuevo enlace
  describe "POST /links" do
    it "crea un nuevo enlace correctamente" do
      expect {
        post "/links", params: { link: { title: "Nuevo Enlace", url: "http://nuevoenlace.com" } }
      }.to change(Link, :count).by(1)

      follow_redirect!
      expect(response.body).to include("Nuevo Enlace") # Verifica que el nuevo enlace aparece en la vista
    end
  end

  # Test para actualizar un enlace existente
  describe "PATCH /links/:id" do
    it "actualiza un enlace existente" do
      patch "/links/#{link.id}", params: { link: { title: "Enlace Actualizado" } }
      link.reload
      expect(link.title).to eq("Enlace Actualizado") # Verifica que el título se actualizó
    end
  end

  # Test para eliminar un enlace
  describe "DELETE /links/:id" do
    it "elimina un enlace existente" do
      expect {
        delete "/links/#{link.id}"
      }.to change(Link, :count).by(-1) # Verifica que se eliminó
    end
  end
end
