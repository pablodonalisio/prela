require "rails_helper"

RSpec.describe "/location_equipments", type: :request do
  before { sign_in user }

  let(:user) { create(:admin) }

  describe "GET /index" do
    let!(:users) { create_list(:user, 3) }

    it "renders a successful response and responds with HTML" do
      get users_url
      expect(response).to be_successful
      users.each do |user|
        expect(response.body).to include(user.email)
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not render the index page" do
        get users_url
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
        expect(response.body).not_to include(users.first.email)
      end
    end
  end

  describe "POST /create" do
    let(:params) do
      {
        user: {
          email: "test@test.com",
          password: "password123",
          role: "client",
          editor: true
        }
      }
    end
    let(:request) { post users_url, params: params }

    it "creates a new User" do
      expect {
        request
      }.to change(User, :count).by(1)
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not allow creating a new user" do
        expect {
          request
        }.not_to change(User, :count)
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT /update" do
    let(:user_to_update) { create(:user) }
    let(:params) do
      {
        id: user_to_update.id,
        user: {
          email: "newemail@test.com",
          password: "newpassword123",
          role: "client",
          editor: true
        }
      }
    end
    let(:request) { put user_url(user_to_update), params: params }

    it "updates the requested user" do
      request
      user_to_update.reload
      expect(user_to_update.email).to eq("newemail@test.com")
      expect(user_to_update.role).to eq("client")
      expect(user_to_update.editor).to be true
      expect(response).to redirect_to(users_url)
      expect(flash[:notice]).to eq("Usuario actualizado exitosamente")
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not allow updating a user" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:user_to_delete) { create(:user) }
    let(:request) { delete user_url(user_to_delete) }

    it "destroys the requested user" do
      expect {
        request
      }.to change(User, :count).by(-1)
      expect(flash[:notice]).to eq("El usuario ha sido eliminado.")
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not allow deleting a user" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("No estás autorizado para realizar esta acción.")
      end
    end
  end

  context "when user is a technician" do
    let(:user) { create(:technician) }
    let!(:other_user) { create(:user, email: "other-account@example.com") }

    it "lists only their own account" do
      get users_url

      expect(response).to be_successful
      expect(response.body).to include(user.email)
      expect(response.body).not_to include(other_user.email)
      expect(response.body).not_to include("Agregar")
      expect(response.body).not_to include("Eliminar")
    end

    it "edits only their email and password" do
      get edit_user_path(user)

      expect(response).to be_successful
      expect(response.body).to include("Email")
      expect(response.body).not_to include("user[role]")
      expect(response.body).not_to include("user[editor]")
      expect(response.body).not_to include("user[client_id]")
    end

    it "updates their own email without changing their role" do
      put user_url(user), params: {user: {email: "technician-updated@example.com", role: "admin"}}

      user.reload
      expect(user.email).to eq("technician-updated@example.com")
      expect(user).to be_technician
      expect(response).to redirect_to(users_url)
    end

    it "does not update another user" do
      put user_url(other_user), params: {user: {email: "hacked@example.com"}}

      expect(response).to redirect_to(root_path)
      expect(other_user.reload.email).to eq("other-account@example.com")
    end
  end
end
