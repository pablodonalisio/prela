require "rails_helper"

RSpec.describe EquipmentKindsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/equipment_kinds").to route_to("equipment_kinds#index")
    end

    it "routes to #new" do
      expect(get: "/equipment_kinds/new").to route_to("equipment_kinds#new")
    end

    it "routes to #show" do
      expect(get: "/equipment_kinds/1").to route_to("equipment_kinds#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/equipment_kinds/1/edit").to route_to("equipment_kinds#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/equipment_kinds").to route_to("equipment_kinds#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/equipment_kinds/1").to route_to("equipment_kinds#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/equipment_kinds/1").to route_to("equipment_kinds#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/equipment_kinds/1").to route_to("equipment_kinds#destroy", id: "1")
    end

    it "routes to #add_field" do
      expect(get: "/equipment_kinds/add_field").to route_to("equipment_kinds#add_field")
    end
  end
end
