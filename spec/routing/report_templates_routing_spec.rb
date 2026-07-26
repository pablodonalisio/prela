require "rails_helper"

RSpec.describe ReportTemplatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/report_templates").to route_to("report_templates#index")
    end

    it "routes to #new" do
      expect(get: "/report_templates/new").to route_to("report_templates#new")
    end

    it "routes to #edit" do
      expect(get: "/report_templates/1/edit").to route_to("report_templates#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/report_templates").to route_to("report_templates#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/report_templates/1").to route_to("report_templates#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/report_templates/1").to route_to("report_templates#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/report_templates/1").to route_to("report_templates#destroy", id: "1")
    end

    it "routes to #add_field" do
      expect(get: "/report_templates/add_field").to route_to("report_templates#add_field")
    end
  end
end
