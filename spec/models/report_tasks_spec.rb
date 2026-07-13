require "rails_helper"

RSpec.describe Report, type: :model do
  describe "task seeding" do
    let(:report_template) { create(:report_template, :with_measurements, :with_tasks) }
    let(:location_equipment) { create(:location_equipment) }

    it "copies template tasks onto a new report when none are provided" do
      report = build(:report, :template_based, location_equipment: location_equipment, report_template: report_template)

      expect { report.save! }.to change(ReportTask, :count).by(2)
      expect(report.report_tasks.order(:position).map(&:name)).to eq(
        ["Limpieza general", "Verificación de torque"]
      )
      expect(report.report_tasks.map(&:completed?)).to all(be false)
    end

    it "does not override submitted report tasks" do
      report = build(:report, :template_based, location_equipment: location_equipment, report_template: report_template)
      report.report_tasks_attributes = [
        {name: "Tarea custom", completed: true, position: 0}
      ]

      report.save!
      expect(report.report_tasks.map(&:name)).to eq(["Tarea custom"])
      expect(report.report_tasks.first).to be_completed
    end
  end
end
