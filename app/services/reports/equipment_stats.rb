class Reports::EquipmentStats
  PRIMARY_COLOR = "DACFE8"

  def initialize(report, pdf)
    @report = report
    @pdf = pdf
  end

  def render
    equipment_data
    equipment_stats
    @pdf
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
      [{content: "PLANILLA DE OBSEVACION", colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}],
      [{}, {content: "Valor Observado", font_style: :bold, align: :center}, {content: "Óptimo", font_style: :bold, align: :center}],
      [{content: "Modo de funcionamiento"}, {}, {}],
      [{content: "Carga asociada"}, {}, {}],
      [{content: "Carga de la batería"}, {}, {}],
      [{content: "Voltaje de entrada"}, {}, {}],
      [{content: "Voltaje de salida"}, {}, {}],
      [{content: "Estado de PAT"}, {}, {}],
      [{content: "Existencia de alarmas"}, {}, {}],
      [{content: "Estado de ventilación"}, {}, {}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end

  def location_equipment
    @location_equipment ||= @report.location_equipment
  end

  def equipment
    @equipment ||= location_equipment.equipment
  end
end
