require "rails_helper"

RSpec.describe "Homes", type: :request do
  before { sign_in create(:admin) }

  describe "GET /index" do
    it "returns http success" do
      get "/home/index"
      expect(response).to have_http_status(:success)
    end

    context "control panel" do
      before do
        allow_any_instance_of(LocationEquipment).to receive(:create_next_service_dates).and_return(nil)
      end

      let!(:location_equipment) { create(:location_equipment) }
      let!(:overdue_service_date) { create(:service_date, location_equipment:, kind: :service, date: 2.months.ago) }
      let!(:non_overdue_service_date) { create(:service_date, location_equipment:, kind: :battery_change, date: 4.months.from_now) }

      it "shows all services with overdue maintenance to admins" do
        get "/home/index"
        expect(response.body).to include(/Tipo: #{ServiceDate.human_attribute_name(overdue_service_date.kind)}/)
        expect(response.body).not_to include(/Tipo: #{ServiceDate.human_attribute_name(non_overdue_service_date.kind)}/)
      end

      context "when user is not admin" do
        let(:user) { create(:user, client: create(:client)) }
        let!(:client_location_equipment) { create(:location_equipment, location: create(:location, client: user.client)) }
        let!(:client_overdue_service_date) { create(:service_date, location_equipment: client_location_equipment, kind: :service, date: 2.months.ago) }
        let!(:client_non_overdue_service_date) { create(:service_date, location_equipment: client_location_equipment, kind: :battery_change, date: 4.months.from_now) }
        let!(:non_client_overdue_service_date) { create(:service_date, location_equipment:, kind: :service, date: 3.months.ago) }

        before do
          sign_in user
          allow_any_instance_of(LocationEquipment).to receive(:create_next_service_dates).and_return(nil)
        end

        it "only shows services that belongs to the user's client" do
          get "/home/index"
          expect(response.body).to include("Cliente: #{user.client.name}")
          expect(response.body).to include("Fecha: #{client_overdue_service_date.date.strftime("%d/%m/%Y")}")
          expect(response.body).not_to include("Fecha: #{client_non_overdue_service_date.date.strftime("%d/%m/%Y")}")
          expect(response.body).not_to include("Fecha: #{non_client_overdue_service_date.date.strftime("%d/%m/%Y")}")
        end
      end
    end
  end
end
