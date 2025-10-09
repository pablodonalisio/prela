class Reports::Equipment::ElectricalPanelStats < Reports::Content
  def render
    electrical_panel_stats
    super
  end

  private

  def electrical_panel_stats
    @pdf.move_down 10
    table_width = @pdf.bounds.width
    visual_inspection_table(table_width)
    power_supply_table(table_width)
    @pdf.start_new_page
    protections_table(table_width)
    conductors_table(table_width)
    @pdf.start_new_page
    measurements_on_panel_table(table_width)
    pat_table(table_width)
  end

  def visual_inspection_table(table_width)
    @pdf.table([
      [{content: "INSPECCION GENERAL VISUAL", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{content: "Dimensiones"}, {content: stats.dimensions, colspan: 2}],
      [{content: "Superficie donde se encuentra"}, {content: stats.mounting_surface, colspan: 2}],
      [{content: "Estado físico"}, {content: stats.physical_state, colspan: 2}],
      [{content: "Indicadores luminosos de presencia de tensión"}, {content: stats.voltage_presence_lights_in_operation, colspan: 2}],
      [{content: "Etiquetado del tablero"}, {content: stats.panel_labeling, colspan: 2}],
      [{content: "Interruptor de corte general"}, {content: general_cutoff_switch_present? ? "Posee" : "No posee", colspan: 2}],
      [{content: "Llave"}, {content: stats.key, colspan: 2}],
      [{content: "Limpieza del gabinete"}, {content: stats.cabinet_cleaning, colspan: 2}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..2).align = :center
    end
  end

  def power_supply_table(table_width)
    @pdf.table([
      [{content: "ALIMENTACIÓN", colspan: 6, background_color: PRIMARY_COLOR, align: :center}],
      [{content: "Cantidad y sección", colspan: 2}, {content: stats.power_quantity_and_section, colspan: 4}],
      [{content: "Tipo de cable", colspan: 2}, {content: stats.power_cable_type, colspan: 4}],
      colorimetry_header,
      colorimetry_data,
      [{content: "Secuencia de rotacion", colspan: 2}, {content: stats.power_rotation_sequency, colspan: 4}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 6
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..5).align = :center
    end
  end

  def protections_table(table_width)
    @pdf.table([
      [{content: "PROTECCIONES Y CONTENIDO", colspan: 5, background_color: PRIMARY_COLOR, align: :center}],
      *general_cutoff_switch_row,
      [{content: "Tipo de tablero", colspan: 2}, {content: stats.panel_type, colspan: 3}],
      [{content: "Descargador atmosférico", colspan: 2}, {content: stats.operational_atmospheric_discharger, colspan: 3}],
      [{content: "Distribuidor o barras", colspan: 2}, {content: stats.distributor_or_bars_present? ? "Si" : "No"}, {content: "N libres", font_style: :bold}, {content: stats.distributor_or_bars_present? ? stats.distributor_or_bars.to_s : ""}],
      [{content: "Circuitos sin diferenciales", colspan: 2}, {content: stats.circuits_without_differentials_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.circuits_without_differentials_present? ? stats.circuits_without_differentials.to_s : ""}],
      [{content: "Circuitos sin térmicas", colspan: 2}, {content: stats.circuits_without_thermal_keys_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.circuits_without_thermal_keys_present? ? stats.circuits_without_thermal_keys.to_s : ""}],
      [{content: "Protecciones alimentadas en girnaldas", colspan: 2}, {content: stats.protections_powered_on_garlands_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.protections_powered_on_garlands_present? ? stats.protections_powered_on_garlands.to_s : ""}],
      [{content: "Protecciones como borneras", colspan: 2}, {content: stats.protections_such_as_terminal_blocks_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.protections_such_as_terminal_blocks_present? ? stats.protections_such_as_terminal_blocks.to_s : ""}],
      [{content: "Aparamentas fuera de lugar", rowspan: 2, colspan: 2}, {content: stats.misplaced_switchgears_present? ? "Si" : "No", rowspan: 2}, {content: "Cuantos", font_style: :bold}, {content: stats.misplaced_switchgears_present? ? stats.misplaced_switchgears.to_s : ""}],
      [{content: "Tipo", font_style: :bold}, {content: stats.misplaced_switchgears_present? ? stats.switchgear_type : ""}],
      [{content: "Aparamentas especializadas", rowspan: 2, colspan: 2}, {content: stats.specialized_switchgears_present? ? "Si" : "No", rowspan: 2}, {content: "Cuantos", font_style: :bold}, {content: stats.specialized_switchgears_present? ? stats.specialized_switchgears.to_s : ""}],
      [{content: "Tipo", font_style: :bold}, {content: stats.specialized_switchgears_present? ? stats.specialized_switchgear_type : ""}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 5
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..4).align = :center
    end
  end

  def conductors_table(table_width)
    @pdf.table([
      [{content: "CONDUCTORES", colspan: 5, background_color: PRIMARY_COLOR, align: :center}],
      [{content: "Sin terminales?", colspan: 2}, {content: stats.conductors_without_terminals_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.conductors_without_terminals_present? ? stats.conductors_without_terminals.to_s : ""}],
      [{content: "Subdimensionados para su protección?", colspan: 2}, {content: stats.undersized_conductors_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.undersized_conductors_present? ? stats.undersized_conductors.to_s : ""}],
      [{content: "Con envejecimiento marcado?", colspan: 2}, {content: stats.conductors_with_marked_aging_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.conductors_with_marked_aging_present? ? stats.conductors_with_marked_aging.to_s : ""}],
      [{content: "Con colorimetría clara?", colspan: 2}, {content: stats.conductors_with_clear_colorimetry_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.conductors_with_clear_colorimetry_present? ? stats.conductors_with_clear_colorimetry.to_s : ""}],
      [{content: "Con empalmes?", colspan: 2}, {content: stats.conductors_with_splices_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.conductors_with_splices_present? ? stats.conductors_with_splices.to_s : ""}],
      [{content: "Sobrecalentados?", colspan: 2}, {content: stats.overheated_conductors_present? ? "Si" : "No"}, {content: "Cuantos", font_style: :bold}, {content: stats.overheated_conductors_present? ? stats.overheated_conductors.to_s : ""}],
      [{content: "Orden de los cables", colspan: 2}, {content: stats.conductors_cable_order, colspan: 3}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 5
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..4).align = :center
    end
  end

  def measurements_on_panel_table(table_width)
    @pdf.table([
      [{content: "MEDICIONES SOBRE TABLEROS", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{content: "Temperatura promedio"}, {content: stats.average_temperature.to_s, colspan: 2}],
      [{content: "Presencia de puntos calientes"}, {content: stats.hot_spots_presence? ? "Si" : "No", colspan: 2}],
      *amperage_rows,
      *voltage_rows
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..2).align = :center
    end
  end

  def pat_table(table_width)
    @pdf.table([
      [{content: "PAT", colspan: 3, background_color: PRIMARY_COLOR, align: :center}],
      [{content: "Presencia de barras PAT"}, {content: stats.pat_bars_presence? ? "No" : "Si", colspan: 2}],
      [{content: "Estado del cable tierra"}, {content: stats.ground_cable_status, colspan: 2}],
      [{content: "Continuidad del cable con circuitos"}, {content: stats.pat_cable_continuity_with_circuits? ? "No" : "Si", colspan: 2}],
      [{content: "Sección del cable PAT"}, {content: stats.pat_cable_section, colspan: 2}],
      [{content: "Equipotenciación del gabinete"}, {content: stats.cabinet_equipotentialization? ? "No" : "Si", colspan: 2}],
      [{content: "Presencia de empalmes"}, {content: stats.pat_splices_presence? ? "No" : "Si", colspan: 2}]
    ], width: table_width) do
      cells.border_color = PRIMARY_COLOR
      cells.width = table_width / 3
      rows(0).font_style = :bold
      columns(0).font_style = :bold
      columns(0..2).align = :center
    end
  end

  def stats
    @report.electrical_panel_report_stat
  end

  def colorimetry_header
    if equipment.is_triphase?
      [{content: "Colorimetría", rowspan: 2, colspan: 2}, {content: "N", font_style: :bold}, {content: "L1", font_style: :bold}, {content: "L2", font_style: :bold}, {content: "L3", font_style: :bold}]
    else
      [{content: "Colorimetría", rowspan: 2, colspan: 2}, {content: "N", font_style: :bold, colspan: 2}, {content: "L", font_style: :bold, colspan: 2}]
    end
  end

  def colorimetry_data
    if equipment.is_triphase?
      [{content: stats.neutral_color}, {content: stats.l1_color}, {content: stats.l2_color}, {content: stats.l3_color}]
    else
      [{content: stats.neutral_color, colspan: 2}, {content: stats.l1_color, colspan: 2}]
    end
  end

  def amperage_rows
    if equipment.is_triphase?
      [
        [{content: "Consumos", rowspan: 4}, {content: "Fase 1", font_style: :bold}, {content: "#{stats.l1_amperage} A"}],
        [{content: "Fase 2", font_style: :bold}, {content: "#{stats.l2_amperage} A"}],
        [{content: "Fase 3", font_style: :bold}, {content: "#{stats.l3_amperage} A"}],
        [{content: "Neutro", font_style: :bold}, {content: "#{stats.neutral_amperage} A"}]
      ]
    else
      [
        [{content: "Consumos", rowspan: 2}, {content: "Fase", font_style: :bold}, {content: "#{stats.l1_amperage} A"}],
        [{content: "Neutro", font_style: :bold}, {content: "#{stats.neutral_amperage} A"}]
      ]
    end
  end

  def voltage_rows
    if equipment.is_triphase?
      [
        [{content: "Tensiones", rowspan: 7}, {content: "L1 neutro", font_style: :bold}, {content: "#{stats.l1_neutral_voltage} V"}],
        [{content: "L2 neutro", font_style: :bold}, {content: "#{stats.l2_neutral_voltage} V"}],
        [{content: "L3 neutro", font_style: :bold}, {content: "#{stats.l3_neutral_voltage} V"}],
        [{content: "L1 L2", font_style: :bold}, {content: "#{stats.l1_l2_voltage} V"}],
        [{content: "L2 L3", font_style: :bold}, {content: "#{stats.l2_l3_voltage} V"}],
        [{content: "L3 L1", font_style: :bold}, {content: "#{stats.l3_l1_voltage} V"}],
        [{content: "N y tierra", font_style: :bold}, {content: "#{stats.neutral_pe_voltage} V"}]
      ]
    else
      [
        [{content: "Tensiones", rowspan: 3}, {content: "Fase Neutro", font_style: :bold}, {content: "#{stats.l1_neutral_voltage} V"}],
        [{content: "N y tierra", font_style: :bold}, {content: "#{stats.neutral_pe_voltage} V"}],
        [{content: "Fase y tierra", font_style: :bold}, {content: "#{stats.l1_pe_voltage} V"}]
      ]
    end
  end

  def general_cutoff_switch_present?
    stats.general_cutoff_switch_present?
  end

  def general_cutoff_switch_row
    if general_cutoff_switch_present?
      [
        [{content: "Modelo interruptor de corte general", rowspan: 2, colspan: 2}, {content: "Modelo", colspan: 2, font_style: :bold}, {content: stats.general_cutoff_switch_model}],
        [{content: "Límite de protección", colspan: 2, font_style: :bold}, {content: stats.general_cutoff_switch_protection_limit}]
      ]
    else
      [
        [{content: "Modelo interruptor de corte general", colspan: 2}, {content: "No posee", colspan: 3}]
      ]
    end
  end
end
