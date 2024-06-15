class Reports::Equipment::UpsStats < Reports::Content
  def render
    ups_stats
    super
  end

  private

  def ups_stats
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: "PLANILLA DE OBSEVACION", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
      [{content: "Modo de funcionamiento"}, {content: ups_report_stat.operating_mode}, {content: "Normal"}],
      [{content: "Carga asociada"}, {content: "#{ups_report_stat.associated_charge}%"}, {content: "-"}],
      [{content: "Carga de la batería"}, {content: "#{ups_report_stat.battery_charge}%"}, {content: "-"}],
      [{content: "Voltaje de entrada"}, {content: "#{ups_report_stat.voltage_input} V"}, {content: "220 V± 10%"}],
      [{content: "Voltaje de salida"}, {content: "#{ups_report_stat.voltage_output} V"}, {content: "220 V± 10%"}],
      [{content: "Estado de PAT"}, {content: ups_report_stat.pat_state}, {content: "Correcto"}],
      [{content: "Existencia de alarmas"}, {content: ups_report_stat.alarms_presence}, {content: "Ninguna"}],
      [{content: "Estado de ventilación"}, {content: ups_report_stat.ventilation_state}, {content: "Normal"}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0..1).font_style = :bold
      columns(1..2).align = :center
    end
  end

  def ups_report_stat
    @report.ups_report_stat
  end
end
