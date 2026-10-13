FactoryBot.define do
  factory :report_template do
    sequence(:name) { |n| "Plantilla de informe #{n}" }

    trait :with_measurements do
      after(:create) do |template|
        text_kind = SectionKind.fetch("text")
        table_kind = SectionKind.fetch("table")
        images_kind = SectionKind.fetch("images")

        notes = template.sections.create!(title: "Notas", position: 0, section_kind: text_kind)
        notes.text_section.update!(body: "Texto base")

        measurements = template.sections.create!(
          title: "Tensión L1",
          position: 1,
          section_kind: table_kind,
          table_section_attributes: {
            row_count: 1,
            column_count: 2,
            table_labels_attributes: {
              "0" => {axis: "corner", position: 0, label: "Concepto"},
              "1" => {axis: "column", position: 0, label: "Fase"},
              "2" => {axis: "column", position: 1, label: "Medición"},
              "3" => {axis: "row", position: 0, label: "Línea 1"}
            }
          }
        )
        table = measurements.table_section
        table.table_cells.find_by!(row_index: 0, column_index: 0).update!(
          value_type: "string",
          value: "L1",
          fixed: true,
          for_metrics: false
        )
        table.table_cells.find_by!(row_index: 0, column_index: 1).update!(
          value_type: "float",
          fixed: false,
          for_metrics: true
        )

        template.sections.create!(title: "Fotos", position: 2, section_kind: images_kind)
      end
    end

    trait :with_list do
      after(:create) do |template|
        next_position = template.sections.maximum(:position)
        template.sections.create!(
          title: "Protocolo",
          position: next_position.nil? ? 0 : next_position + 1,
          section_kind: SectionKind.fetch("list"),
          list_section_attributes: {
            list_items_attributes: {
              "0" => {name: "Limpieza general", position: 0},
              "1" => {name: "Verificación de torque", position: 1}
            }
          }
        )
      end
    end
  end
end
