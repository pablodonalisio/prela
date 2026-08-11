require "rails_helper"

RSpec.describe "/tags", type: :request do
  let(:valid_attributes) { {name: "Inaccesible", color: "#ffc107"} }
  let(:invalid_attributes) { {name: nil} }
  let(:user) { create(:admin) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      Tag.create! valid_attributes
      get tags_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get tags_url
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_tag_url
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get new_tag_url
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      tag = Tag.create! valid_attributes
      get edit_tag_url(tag)
      expect(response).to be_successful
    end

    context "when user is not admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        tag = Tag.create! valid_attributes
        get edit_tag_url(tag)
        expect(flash[:alert]).to eq "No estas autorizado para realizar esta acción."
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Tag" do
        expect {
          post tags_url, params: {tag: valid_attributes}
        }.to change(Tag, :count).by(1)
      end

      it "redirects to the tags list" do
        post tags_url, params: {tag: valid_attributes}
        expect(response).to redirect_to(tags_url)
      end

      it "appends the tag via turbo stream" do
        post tags_url, params: {tag: valid_attributes}, as: :turbo_stream
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('turbo-stream action="append" target="tags"')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Tag" do
        expect {
          post tags_url, params: {tag: invalid_attributes}
        }.to change(Tag, :count).by(0)
      end

      it "renders a response with 422 status" do
        post tags_url, params: {tag: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the form via turbo stream" do
        post tags_url, params: {tag: invalid_attributes}, as: :turbo_stream
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('turbo-stream action="update" target="remote_modal_body"')
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { {name: "PRELA para revisar", color: "#dc3545"} }

      it "updates the requested tag" do
        tag = Tag.create! valid_attributes
        patch tag_url(tag), params: {tag: new_attributes}
        tag.reload
        expect(tag.name).to eq "PRELA para revisar"
        expect(tag.color).to eq "#dc3545"
      end


      it "redirects to the tags list" do
        tag = Tag.create! valid_attributes
        patch tag_url(tag), params: {tag: new_attributes}
        expect(response).to redirect_to(tags_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status" do
        tag = Tag.create! valid_attributes
        patch tag_url(tag), params: {tag: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "soft-deletes the requested tag" do
      tag = Tag.create! valid_attributes
      expect {
        delete tag_url(tag)
      }.to change(Tag.kept, :count).by(-1)
      expect(tag.reload).to be_discarded
    end

    it "redirects to the tags list" do
      tag = Tag.create! valid_attributes
      delete tag_url(tag)
      expect(response).to redirect_to(tags_url)
    end
  end
end
