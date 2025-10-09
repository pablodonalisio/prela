class Reports::EquipmentStats < Reports::Content
  def render
    equipment_data
    equipment_stats
    super
  end

  private

  def equipment_data
    table_width = @pdf.bounds.width
    @pdf.table(equipment_data_rows, width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end

  def equipment_stats
    if equipment.ups?
      @pdf = Reports::Equipment::UpsStats.new(@report, @pdf).render
    elsif equipment.power_unit?
      @pdf = Reports::Equipment::PowerUnitStats.new(@report, @pdf).render
    elsif equipment.electrical_panel?
      @pdf = Reports::Equipment::ElectricalPanelStats.new(@report, @pdf).render
    else
      raise StandardError, "El tipo de equipo no posee estadísticas definidas"
    end
  end

  def equipment_data_rows
    rows = []
    rows << data_header
    rows << equipment_name_row
    rows << equipment_power_row if equipment.kva.present?
    rows << equipment_serial_row if location_equipment.serial_number.present?
    rows
  end

  def data_header
    [{content: location_equipment.code, colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}]
  end

  def equipment_name_row
    return [{content: "Nombre del Tablero"}, {content: equipment.model.upcase, colspan: 2, align: :right}] if equipment.electrical_panel?

    [{content: "Marca - Modelo"}, {content: equipment.full_name, colspan: 2, align: :right}]
  end

  def equipment_power_row
    [{content: "Potencia"}, {content: "#{equipment.kva} kVA", colspan: 2, align: :right}]
  end

  def equipment_serial_row
    [{content: "Numero de Serie"}, {content: location_equipment.serial_number, colspan: 2, align: :right}]
  end
end
