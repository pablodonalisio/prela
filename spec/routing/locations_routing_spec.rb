require "rails_helper"

RSpec.describe LocationsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "clients/1/locations/new").to route_to("locations#new", client_id: "1")
    end

    it "routes to #edit" do
      expect(get: "clients/1/locations/1/edit").to route_to("locations#edit", id: "1", client_id: "1")
    end

    it "routes to #create" do
      expect(post: "clients/1/locations").to route_to("locations#create", client_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/clients/1/locations/1").to route_to("locations#update", client_id: "1", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/clients/1/locations/1").to route_to("locations#update", client_id: "1", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/clients/1/locations/1").to route_to("locations#destroy", client_id: "1", id: "1")
    end
  end
end
