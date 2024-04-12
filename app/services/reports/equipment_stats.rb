class Reports::EquipmentStats < Reports::Content
  def render
    equipment_data
    equipment_stats
    super
  end

  private

  def equipment_data
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: location_equipment.code, colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}],
      [{content: "Marca - Modelo"}, {content: equipment.full_name, colspan: 2, align: :right}],
      [{content: "Potencia"}, {content: "#{equipment.kva} kVA", colspan: 2, align: :right}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end

  def equipment_stats
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: "PLANILLA DE OBSEVACION", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
      [{content: "Modo de funcionamiento"}, {}, {content: "Normal"}],
      [{content: "Carga asociada"}, {}, {content: "-"}],
      [{content: "Carga de la batería"}, {}, {content: "-"}],
      [{content: "Voltaje de entrada"}, {}, {content: "220 V± 10%"}],
      [{content: "Voltaje de salida"}, {}, {content: "220 V± 10%"}],
      [{content: "Estado de PAT"}, {}, {content: "Correcto"}],
      [{content: "Existencia de alarmas"}, {}, {content: "Ninguna"}],
      [{content: "Estado de ventilación"}, {}, {content: "Normal"}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0..1).font_style = :bold
      columns(1..2).align = :center
    end
  end
end
