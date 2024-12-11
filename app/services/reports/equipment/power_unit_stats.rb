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
      [{content: "Seccionador general"}, {content: power_unit_report_stat.general_disconnector}, {content: "ON"}],
      [{content: "Posición parada de emergencia"}, {content: power_unit_report_stat.emergency_stop_position}, {content: "OFF"}],
      [{content: "Llave encendido en posición AUTO"}, {content: power_unit_report_stat.start_key_on_auto.to_s}, {content: ""}],
      [{content: "R.P.M."}, {content: data_present?(power_unit_report_stat.rpm, "rpm")}, {content: "~1500 rpm"}],
      [{content: "Frecuencia (Hz)"}, {content: data_present?(power_unit_report_stat.frequency, "Hz")}, {content: "~50 Hz"}],
      [{content: "Control de carga de baterías (V)"}, {content: "#{power_unit_report_stat.battery_charge_control} Vcc"}, {content: ">26 Vcc"}],
      [{content: "Tensión entre fases A-B (V)"}, {content: data_present?(power_unit_report_stat.tension_between_phases_a_b, "V")}, {content: "~380 V"}],
      [{content: "Tensión entre fases B-C (V)"}, {content: data_present?(power_unit_report_stat.tension_between_phases_b_c, "V")}, {content: "~380 V"}],
      [{content: "Tensión entre fases C-A (V)"}, {content: data_present?(power_unit_report_stat.tension_between_phases_c_a, "V")}, {content: "~380 V"}],
      [{content: "Temperatura inicial (°C)"}, {content: data_present?(power_unit_report_stat.initial_temperature, "°C")}, {content: ">20°C"}],
      [{content: "Temperatura en marcha (°C)"}, {content: data_present?(power_unit_report_stat.running_temperature, "°C")}, {content: ">40°C"}],
      [{content: "Número de arranques"}, {content: data_present?(power_unit_report_stat.number_of_starts)}, {content: "-"}],
      [{content: "Tiempo de funcionamiento (Hs)"}, {content: data_present?(power_unit_report_stat.operating_time)}, {content: "HS"}],
      [{content: "Arranques fallidos"}, {content: data_present?(power_unit_report_stat.failed_starts)}, {content: "-"}],
      [{content: "Presión de aceite"}, {content: "#{power_unit_report_stat.oil_pressure} #{power_unit_report_stat.oil_pressure_unit}"}, {content: ">4 bar"}],
      [{content: "Nivel de combustible"}, {content: data_present?(power_unit_report_stat.fuel_level)}, {content: ">3/4"}],
      [{content: "Nivel de refrigerante"}, {content: power_unit_report_stat.coolant_level.to_s}, {content: "Full"}],
      [{content: "Nivel de aceite"}, {content: power_unit_report_stat.oil_level.to_s}, {content: "Full"}],
      [{content: "Tiempo de prueba (Min.)"}, {content: "#{power_unit_report_stat.testing_time}'"}, {content: ">10'"}],
      [{content: "Test de lámparas"}, {content: power_unit_report_stat.lamp_test}, {content: "Bien"}],
      [{content: "Estado y tensión de correas"}, {content: power_unit_report_stat.belt_condition}, {content: "Bien"}],
      [{content: "Estado de filtro de aire"}, {content: power_unit_report_stat.air_filter_condition}, {content: "Bien"}],
      [{content: "Estado de tacos antivibratorios"}, {content: power_unit_report_stat.anti_vibration_pad_condition}, {content: "Bien"}],
      [{content: "Pérdida de fluídos"}, {content: power_unit_report_stat.liquids_leaks}, {content: "No"}],
      [{content: "Estado de conexiones y fijación de baterías"}, {content: power_unit_report_stat.connections_condition_and_battery_fixation}, {content: "OK"}],
      [{content: "Estado de cables y conexiones eléctricas"}, {content: power_unit_report_stat.cable_and_electrical_connections}, {content: "OK"}]
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

  def data_present?(attribute, suffix = "")
    attribute.to_i.eql?(-1) ? "Sin datos" : "#{attribute} #{suffix}"
  end
end
