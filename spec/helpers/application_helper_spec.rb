require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#sidebar_links" do
    def visible_labels_for(user)
      allow(helper).to receive(:current_user).and_return(user)
      helper.sidebar_links.select { |link| helper.sidebar_link_visible?(link) }.map { |link| link[:text] }
    end

    it "shows every link to admins" do
      expect(visible_labels_for(build(:admin))).to eq(["Home", "Agenda", "Activos", "Informes", "Clientes", "Insumos"])
    end

    it "hides Informes from technicians" do
      expect(visible_labels_for(build(:technician))).to eq(["Home", "Agenda", "Activos", "Clientes", "Insumos"])
    end

    it "shows only the shared links to clients" do
      expect(visible_labels_for(build(:user))).to eq(["Home", "Agenda", "Activos"])
    end
  end
end
