class ElectricalPanelReportStat < ApplicationRecord
  MOUNTING_SURFACE_OPTIONS = ["Empotrado", "Sobre mampostería", "Durlock", "Poste"]
  PHYSICAL_STATE_OPTIONS = ["Perfecto", "Deficiente", "Malo"]
  PANEL_LABELING_OPTIONS = ["Perfecto", "Deficiente", "Malo", "Inexistente"]
  KEY_OPTIONS = ["Sin llave", "Con llave", "Con combinación"]
  CABINET_CLEANING_OPTIONS = ["Perfecto", "Deficiente", "Malo"]
  POWER_CABLE_TYPE_OPTIONS = ["Subterráneo", "TPR", "Unipolares"]
  POWER_ROTATION_SEQUENCY_OPTIONS = ["Horario", "Antihorario"]
  PANEL_TYPE_OPTIONS = ["Seccional", "Principal", "Distribuidor de cargas", "Coseno phi", "Tablero de aislación"]
  CONDUCTORS_CABLE_ORDER_OPTIONS = ["Perfecto", "Bueno", "Deficiente", "Malo"]
  belongs_to :report
end
