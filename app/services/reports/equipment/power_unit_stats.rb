class Reports::Equipment::PowerUnitStats < Reports::Content
  def render
    power_unit_stats
    super
  end

  private

  def power_unit_stats
    table_width = @pdf.bounds.width
    @pdf.table([
      [{content: "PLANILLA DE OBSEVACION", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{}, {content: "Valor Observado"}, {content: "Óptimo"}],
      [{content: "Potencia del equipo"}, {content: power_unit_report_stat.equipment_power}, {content: "OK"}],
      [{content: "Seccionador general"}, {content: power_unit_report_stat.general_disconnector? ? "ON" : "OFF"}, {content: "ON"}],
      [{content: "Posición parada de emergencia"}, {content: power_unit_report_stat.emergency_stop_position? ? "ON" : "OFF"}, {content: "OFF"}],
      [{content: "Llave encendido en posición AUTO"}, {content: power_unit_report_stat.start_key_on_auto.to_s}, {content: "Auto"}],
      [{content: "R.P.M."}, {content: "#{power_unit_report_stat.rpm} rpm"}, {content: "~1500 rpm"}],
      [{content: "Frecuencia (Hz)"}, {content: "#{power_unit_report_stat.frequency} Hz"}, {content: "~50 Hz"}],
      [{content: "Control de carga de baterías (V)"}, {content: "#{power_unit_report_stat.battery_charge_control} Vcc"}, {content: ">26 Vcc"}],
      [{content: "Tensión entre fases A-B (V)"}, {content: "#{power_unit_report_stat.tension_between_phases_a_b} V"}, {content: "~380 V"}],
      [{content: "Tensión entre fases B-C (V)"}, {content: "#{power_unit_report_stat.tension_between_phases_b_c} V"}, {content: "~380 V"}],
      [{content: "Tensión entre fases C-A (V)"}, {content: "#{power_unit_report_stat.tension_between_phases_c_a} V"}, {content: "~380 V"}],
      [{content: "Temperatura inicial (°C)"}, {content: "#{power_unit_report_stat.initial_temperature}°C"}, {content: ">20°C"}],
      [{content: "Temperatura en marcha (°C)"}, {content: "#{power_unit_report_stat.running_temperature}°C"}, {content: ">40°C"}],
      [{content: "Número de arranques"}, {content: power_unit_report_stat.number_of_starts.to_s}, {content: "-"}],
      [{content: "Tiempo de funcionamiento (Hs)"}, {content: power_unit_report_stat.operating_time.to_s}, {content: "HS"}],
      [{content: "Arranques fallidos"}, {content: power_unit_report_stat.failed_starts.to_s}, {content: "-"}],
      [{content: "Presión de aceite"}, {content: "#{power_unit_report_stat.oil_pressure} bar"}, {content: ">4 bar"}],
      [{content: "Nivel de combustible"}, {content: power_unit_report_stat.fuel_level.to_s}, {content: ">3/4"}],
      [{content: "Nivel de refrigerante"}, {content: power_unit_report_stat.coolant_level.to_s}, {content: "Max."}],
      [{content: "Nivel de aceite"}, {content: power_unit_report_stat.oil_level.to_s}, {content: "Full"}],
      [{content: "Tiempo de prueba (Min.)"}, {content: "#{power_unit_report_stat.testing_time}'"}, {content: ">10'"}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0..1).font_style = :bold
      columns(1..2).align = :center
    end
  end

  def power_unit_report_stat
    @report.power_unit_report_stat
  end
end
