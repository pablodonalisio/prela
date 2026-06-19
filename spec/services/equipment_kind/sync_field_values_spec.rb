require "rails_helper"

RSpec.describe EquipmentKind::SyncFieldValues do
  describe ".call" do
    context "when generic fields are renamed" do
      it "does not change related equipment field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "brand" => {"name" => "Marca", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"brand" => "APC"})

        equipment_kind.update!(generic_fields: {
          "brand" => {"name" => "Fabricante", "type" => "string"}
        })

        expect(equipment.reload.field_values).to eq("brand" => "APC")
      end
    end

    context "when generic fields are removed" do
      it "removes keys from related equipment field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "brand" => {"name" => "Marca", "type" => "string"},
          "model" => {"name" => "Modelo", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {
          "brand" => "APC",
          "model" => "Smart-RT"
        })

        equipment_kind.update!(generic_fields: {
          "model" => {"name" => "Modelo", "type" => "string"}
        })

        expect(equipment.reload.field_values).to eq("model" => "Smart-RT")
      end
    end

    context "when specific fields are renamed" do
      it "does not change related location equipment field_values" do
        equipment_kind = create(:equipment_kind, :with_specific_fields)
        equipment = create(:equipment, equipment_kind: equipment_kind)
        location_equipment = create(:location_equipment, equipment: equipment, field_values: {
          "serial_number" => "SN-123"
        })

        equipment_kind.update!(specific_fields: {
          "serial_number" => {"name" => "Serie", "type" => "string"}
        })

        expect(location_equipment.reload.field_values).to eq("serial_number" => "SN-123")
      end
    end

    context "when specific fields are removed" do
      it "removes keys from related location equipment field_values" do
        equipment_kind = create(:equipment_kind, specific_fields: {
          "serial_number" => {"name" => "Número de serie", "type" => "string"},
          "code" => {"name" => "Código", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind)
        location_equipment = create(:location_equipment, equipment: equipment, field_values: {
          "serial_number" => "SN-123",
          "code" => "ABC"
        })

        equipment_kind.update!(specific_fields: {
          "code" => {"name" => "Código", "type" => "string"}
        })

        expect(location_equipment.reload.field_values).to eq("code" => "ABC")
      end
    end

    context "when a new field is added" do
      it "does not change existing field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "brand" => {"name" => "Marca", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"brand" => "APC"})
        new_key = EquipmentKind.generate_field_key

        equipment_kind.update!(generic_fields: {
          "brand" => {"name" => "Marca", "type" => "string"},
          new_key => {"name" => "Modelo", "type" => "string"}
        })

        expect(equipment.reload.field_values).to eq("brand" => "APC")
      end
    end

    context "when only the field type changes" do
      it "preserves existing field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "brand" => {"name" => "Marca", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"brand" => "APC"})

        equipment_kind.update!(generic_fields: {
          "brand" => {"name" => "Marca", "type" => "integer"}
        })

        expect(equipment.reload.field_values).to eq("brand" => "APC")
      end
    end
  end
end
