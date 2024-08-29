class Reports::EquipmentStats < Reports::Content
  def render
    equipment_data
    equipment_stats
    equipment_service_dates
    super
  end

  private

  def equipment_data
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: location_equipment.code, colspan: 3, background_color: PRIMARY_COLOR, font_style: :bold, align: :center}],
      [{content: "Marca - Modelo"}, {content: equipment.full_name, colspan: 2, align: :right}],
      [{content: "Potencia"}, {content: "#{equipment.kva} kVA", colspan: 2, align: :right}],
      [{content: "Numero de Serie"}, {content: location_equipment.serial_number, colspan: 2, align: :right}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
    end
  end

  def equipment_stats
    if equipment.ups?
      @pdf = Reports::Equipment::UpsStats.new(@report, @pdf).render
    elsif equipment.power_unit?
      @pdf = Reports::Equipment::PowerUnitStats.new(@report, @pdf).render
    end
  end

  def equipment_service_dates
    @pdf = Reports::Equipment::ServiceDateStats.new(@report, @pdf).render
  end
end
