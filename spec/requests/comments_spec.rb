require "rails_helper"

RSpec.describe "Comments", type: :request do
  before { sign_in user }

  let(:user) { create(:admin) }
  let(:location_equipment) { create(:location_equipment) }

  describe "GET /new" do
    let(:request) { get new_location_equipment_comment_path(location_equipment) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    it "should instantiate a new comment" do
      request
      doc = Nokogiri::HTML(response.body)
      expect(doc.css('form textarea[name^="comment["]').any?).to be true
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end

  describe "GET /edit" do
    let(:comment) { create(:comment, location_equipment: location_equipment) }
    let(:request) { get edit_location_equipment_comment_path(location_equipment, comment) }

    it "renders a successful response and responds with HTML" do
      request
      expect(response).to be_successful
    end

    it "should instantiate the existing comment" do
      request
      doc = Nokogiri::HTML(response.body)
      expect(doc.css("form textarea[name^=\"comment[\"]").text).to include(comment.description)
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end

  describe "GET /index" do
    it "returns a success response" do
      get location_equipment_comments_path(location_equipment)
      expect(response).to redirect_to(location_equipment_path(location_equipment))
    end
  end

  describe "POST /create" do
    let(:params) {
      {
        comment: {
          description: "Test Comment"
        }
      }
    }
    let(:request) { post location_equipment_comments_path(location_equipment), params: params }

    it "creates a new comment" do
      expect {
        request
      }.to change(Comment, :count).by(1)
    end

    it "redirects to the location_equipment show page" do
      request
      expect(response).to redirect_to(location_equipment)
      expect(flash[:notice]).to match(/El comentario se creó correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { post location_equipment_comments_path(location_equipment), params: params }

      it "does not create a new comment without a description" do
        params[:comment][:description] = ""
        expect {
          request
        }.not_to change(Comment, :count)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        allow_any_instance_of(Comment).to receive(:save).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:comment) { create(:comment, location_equipment: location_equipment) }
    let(:params) {
      {
        comment: {
          description: "Updated Description"
        }
      }
    }
    let(:request) { patch location_equipment_comment_path(location_equipment, comment), params: params }

    it "updates the requested comment" do
      request
      comment.reload
      expect(comment.description).to eq("Updated Description")
    end

    it "redirects to the location_equipment page" do
      request
      expect(response).to redirect_to(location_equipment_path(location_equipment))
      expect(flash[:notice]).to match(/El comentario se editó correctamente./)
    end

    context "with invalid parameters" do
      let(:request) { patch location_equipment_comment_path(location_equipment, comment), params: params }

      it "does not update the comment with invalid data" do
        params[:comment][:description] = ""
        request
        comment.reload
        expect(comment.description).not_to eq("")
      end

      it "renders a successful response (i.e. to display the 'edit' template)" do
        allow_any_instance_of(Comment).to receive(:update).and_return(false)
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:comment) { create(:comment, location_equipment: location_equipment) }
    let(:request) { delete location_equipment_comment_path(location_equipment, comment) }

    it "destroys the requested comment" do
      expect {
        request
      }.to change(Comment, :count).by(-1)
    end

    it "redirects to the location_equipment page" do
      request
      expect(response).to redirect_to(location_equipment_path(location_equipment))
      expect(flash[:notice]).to match(/El comentario ha sido eliminado./)
    end

    context "as non-admin user" do
      let(:user) { create(:user) }

      it "denies access" do
        request
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(/No estas autorizado para realizar esta acción./)
      end
    end
  end
end
