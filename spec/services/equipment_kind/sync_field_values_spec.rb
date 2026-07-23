require "rails_helper"

RSpec.describe EquipmentKind::SyncFieldValues do
  describe ".call" do
    context "when generic fields are renamed" do
      it "does not change related equipment field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "kva" => {"name" => "Kva", "type" => "float"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"kva" => "10"})

        equipment_kind.update!(generic_fields: {
          "kva" => {"name" => "Potencia", "type" => "float"}
        })

        expect(equipment.reload.field_values).to eq("kva" => "10")
      end
    end

    context "when generic fields are removed" do
      it "removes keys from related equipment field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "kva" => {"name" => "Kva", "type" => "float"},
          "manual" => {"name" => "Manual", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {
          "kva" => "10",
          "manual" => "https://example.com"
        })

        equipment_kind.update!(generic_fields: {
          "manual" => {"name" => "Manual", "type" => "string"}
        })

        expect(equipment.reload.field_values).to eq("manual" => "https://example.com")
      end
    end

    context "when specific fields are renamed" do
      it "does not change related location equipment field_values" do
        equipment_kind = create(:equipment_kind, :with_specific_fields)
        equipment = create(:equipment, equipment_kind: equipment_kind)
        location_equipment = create(:location_equipment, equipment: equipment, field_values: {
          "form_link" => "https://example.com/form"
        })

        equipment_kind.update!(specific_fields: {
          "form_link" => {"name" => "Formulario", "type" => "string"}
        })

        expect(location_equipment.reload.field_values).to eq("form_link" => "https://example.com/form")
      end
    end

    context "when specific fields are removed" do
      it "removes keys from related location equipment field_values" do
        equipment_kind = create(:equipment_kind, specific_fields: {
          "form_link" => {"name" => "Link al formulario", "type" => "string"},
          "more_info" => {"name" => "Más info", "type" => "string"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind)
        location_equipment = create(:location_equipment, equipment: equipment, field_values: {
          "form_link" => "https://example.com/form",
          "more_info" => "extra"
        })

        equipment_kind.update!(specific_fields: {
          "more_info" => {"name" => "Más info", "type" => "string"}
        })

        expect(location_equipment.reload.field_values).to eq("more_info" => "extra")
      end
    end

    context "when a new field is added" do
      it "does not change existing field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "kva" => {"name" => "Kva", "type" => "float"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"kva" => "10"})
        new_key = EquipmentKind.generate_field_key

        equipment_kind.update!(generic_fields: {
          "kva" => {"name" => "Kva", "type" => "float"},
          new_key => {"name" => "Modelo técnico", "type" => "string"}
        })

        expect(equipment.reload.field_values).to eq("kva" => "10")
      end
    end

    context "when only the field type changes" do
      it "preserves existing field_values" do
        equipment_kind = create(:equipment_kind, generic_fields: {
          "kva" => {"name" => "Kva", "type" => "float"}
        })
        equipment = create(:equipment, equipment_kind: equipment_kind, field_values: {"kva" => "10"})

        equipment_kind.update!(generic_fields: {
          "kva" => {"name" => "Kva", "type" => "integer"}
        })

        expect(equipment.reload.field_values).to eq("kva" => "10")
      end
    end
  end
end
