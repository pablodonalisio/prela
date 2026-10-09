require "rails_helper"

RSpec.describe "Technician access", type: :policy do
  let(:technician) { create(:technician, editor: true) }
  let(:client_editor) { create(:user, role: :client, editor: true) }

  describe ReportPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Report.new)
      end
    end
  end

  describe ActivityPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Activity.new)
      end
    end
  end

  describe FailurePolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Failure.new)
      end
    end
  end

  describe EquipmentPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Equipment.new)
      end
    end
  end

  describe LocationEquipmentPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, LocationEquipment.new)
      end
    end

    describe "Scope" do
      let(:client_record) { create(:client) }
      let(:another_client) { create(:client) }
      let!(:client_location_equipment) { create(:location_equipment, location: create(:location, client: client_record)) }
      let!(:another_location_equipment) { create(:location_equipment, location: create(:location, client: another_client)) }

      it "returns location equipment for every client" do
        expect(Pundit.policy_scope(technician, LocationEquipment)).to include(client_location_equipment, another_location_equipment)
      end
    end
  end

  describe ServiceOccurrencePolicy do
    let(:occurrence) { ServiceOccurrence.new }

    permissions :show?, :complete? do
      it "grants access" do
        expect(described_class).to permit(technician, occurrence)
      end
    end

    permissions :update? do
      it "denies access even when the technician is marked as an editor" do
        expect(described_class).not_to permit(technician, occurrence)
      end

      it "still grants access to a client editor" do
        expect(described_class).to permit(client_editor, occurrence)
      end
    end
  end

  describe ClientPolicy do
    permissions :index?, :show? do
      it "grants access" do
        expect(described_class).to permit(technician, Client.new)
      end
    end

    permissions :create?, :update?, :destroy? do
      it "denies access" do
        expect(described_class).not_to permit(technician, Client.new)
      end
    end
  end

  describe UserPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "denies access" do
        expect(described_class).not_to permit(technician, User.new)
      end
    end
  end

  describe DocumentPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Document.new)
      end
    end
  end

  describe CommentPolicy do
    permissions :index?, :show?, :create?, :update?, :destroy? do
      it "grants access" do
        expect(described_class).to permit(technician, Comment.new)
      end
    end
  end

  {
    TagPolicy => Tag.new,
    ServiceKindPolicy => ServiceKind.new,
    EquipmentKindPolicy => EquipmentKind.new,
    ReportTemplatePolicy => ReportTemplate.new,
    BatteryPolicy => Battery.new,
    LinkPolicy => Link.new,
    LocationEquipmentServicePolicy => LocationEquipmentService.new
  }.each do |policy_class, record|
    describe policy_class do
      permissions :index?, :show? do
        it "grants access" do
          expect(described_class).to permit(technician, record)
        end
      end

      permissions :create?, :update?, :destroy? do
        it "denies access" do
          expect(described_class).not_to permit(technician, record)
        end
      end
    end
  end

  describe HomePolicy do
    permissions :index? do
      it "grants access" do
        expect(described_class).to permit(technician, :home)
      end
    end
  end

  describe AgendaPolicy do
    permissions :index? do
      it "grants access" do
        expect(described_class).to permit(technician, :agenda)
      end
    end
  end
end
