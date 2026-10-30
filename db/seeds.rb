# Demo clients with contact org charts for local UI review.
# Safe to re-run: rebuilds contacts for these two demo clients only.

def seed_contact!(client:, locations: [], reports_to: nil, distance_above: nil, **attrs)
  distance_above = if distance_above.nil?
    reports_to ? 1 : 0
  else
    distance_above
  end

  client.contacts.create!(
    locations: Array(locations),
    reports_to:,
    distance_above:,
    email: attrs[:email],
    phone: attrs[:phone],
    name: attrs[:name],
    job_position: attrs[:job_position],
    work_area: attrs[:work_area],
    description: attrs[:description]
  )
end

def ensure_location!(client, name)
  location = client.locations.find_or_initialize_by(name:)
  location.undiscard if location.persisted? && location.discarded?
  location.save!
  location
end

def reset_demo_contacts!(client)
  client.contacts.find_each do |contact|
    contact.direct_reports.update_all(reports_to_id: nil)
    contact.discard if contact.kept?
  end
end

puts "Seeding demo client org charts..."

# --- 5-person org -----------------------------------------------------------
small = Client.find_or_create_by!(name: "Demo Org 5")
reset_demo_contacts!(small)
small_hq = ensure_location!(small, "Sede Central")
small_plant = ensure_location!(small, "Planta Anexo")

ceo = seed_contact!(
  client: small,
  locations: [small_hq, small_plant],
  distance_above: 0,
  name: "Laura Méndez",
  job_position: "Directora General",
  work_area: "Dirección",
  email: "laura.mendez@demo5.prela",
  phone: "11-4000-1001",
  description: "A cargo de ambas sedes (distance_above: 0)"
)

ops = seed_contact!(
  client: small,
  locations: [small_hq, small_plant],
  reports_to: ceo,
  distance_above: 1,
  name: "Martín Rivas",
  job_position: "Jefe de Operaciones",
  work_area: "Operaciones",
  email: "martin.rivas@demo5.prela",
  phone: "11-4000-1002",
  description: "Coordina operaciones en ambas sedes"
)

# Gap under ops: missing intermediate supervisor (distance_above: 2)
seed_contact!(
  client: small,
  locations: [small_plant],
  reports_to: ops,
  distance_above: 2,
  name: "Sofía Acosta",
  job_position: "Técnica senior",
  work_area: "Mantenimiento",
  email: "sofia.acosta@demo5.prela",
  phone: "11-4000-1003",
  description: "Hueco visual bajo Operaciones (distance_above: 2)"
)

seed_contact!(
  client: small,
  locations: [small_hq],
  reports_to: ops,
  distance_above: 1,
  name: "Diego Farías",
  job_position: "Técnico",
  work_area: "Mantenimiento",
  email: "diego.farias@demo5.prela",
  phone: "11-4000-1004"
)

seed_contact!(
  client: small,
  locations: [small_hq],
  reports_to: ceo,
  distance_above: 1,
  name: "Valentina Ruiz",
  job_position: "Administrativa",
  work_area: "Administración",
  email: "valentina.ruiz@demo5.prela",
  phone: "11-4000-1005"
)

# Disconnected mid-level root: no superior in system, starts 2 bands down
seed_contact!(
  client: small,
  locations: [small_hq, small_plant],
  distance_above: 2,
  name: "Gustavo Herrera",
  job_position: "Consultor externo EHS",
  work_area: "Seguridad",
  email: "gustavo.herrera@demo5.prela",
  phone: "11-4000-1006",
  description: "Raíz desconectada a mitad de organigrama; cubre ambas sedes"
)

puts "  Demo Org 5: #{small.contacts.kept.count} contacts, #{small.locations.kept.count} locations"

# --- 20-person org ----------------------------------------------------------
large = Client.find_or_create_by!(name: "Demo Org 20")
reset_demo_contacts!(large)

hq = ensure_location!(large, "Casa Central")
north = ensure_location!(large, "Planta Norte")
south = ensure_location!(large, "Planta Sur")
all_sites = [hq, north, south]

gm = seed_contact!(
  client: large,
  locations: all_sites,
  distance_above: 0,
  name: "Ricardo Peña",
  job_position: "Gerente General",
  work_area: "Dirección",
  email: "ricardo.pena@demo20.prela",
  phone: "11-5000-2001",
  description: "A cargo de todas las sedes (distance_above: 0)"
)

ops_dir = seed_contact!(
  client: large,
  locations: all_sites,
  reports_to: gm,
  distance_above: 1,
  name: "Carolina Vázquez",
  job_position: "Directora de Operaciones",
  work_area: "Operaciones",
  email: "carolina.vazquez@demo20.prela",
  phone: "11-5000-2002",
  description: "Opera las tres sedes"
)

fin_dir = seed_contact!(
  client: large,
  locations: [hq],
  reports_to: gm,
  distance_above: 1,
  name: "Andrés Molina",
  job_position: "Director de Finanzas",
  work_area: "Finanzas",
  email: "andres.molina@demo20.prela",
  phone: "11-5000-2003"
)

hr_dir = seed_contact!(
  client: large,
  locations: all_sites,
  reports_to: gm,
  distance_above: 1,
  name: "Patricia Gómez",
  job_position: "Directora de RRHH",
  work_area: "Recursos Humanos",
  email: "patricia.gomez@demo20.prela",
  phone: "11-5000-2004",
  description: "RRHH corporativo para todas las plantas"
)

north_mgr = seed_contact!(
  client: large,
  locations: [north],
  reports_to: ops_dir,
  distance_above: 1,
  name: "Julián Castro",
  job_position: "Jefe de Planta Norte",
  work_area: "Operaciones",
  email: "julian.castro@demo20.prela",
  phone: "11-5000-2101"
)

south_mgr = seed_contact!(
  client: large,
  locations: [south],
  reports_to: ops_dir,
  distance_above: 1,
  name: "Elena Quiroga",
  job_position: "Jefa de Planta Sur",
  work_area: "Operaciones",
  email: "elena.quiroga@demo20.prela",
  phone: "11-5000-2201"
)

# Gap under ops: coordinator reports with distance_above 2 (missing middle layer)
maint_coord = seed_contact!(
  client: large,
  locations: all_sites,
  reports_to: ops_dir,
  distance_above: 2,
  name: "Héctor Blanco",
  job_position: "Coordinador de Mantenimiento",
  work_area: "Mantenimiento",
  email: "hector.blanco@demo20.prela",
  phone: "11-5000-2005",
  description: "Hueco visual bajo Operaciones; cubre las tres sedes"
)

seed_contact!(
  client: large,
  locations: [hq],
  reports_to: fin_dir,
  name: "Marina Ortega",
  job_position: "Analista de Cuentas",
  work_area: "Finanzas",
  email: "marina.ortega@demo20.prela",
  phone: "11-5000-2006"
)

seed_contact!(
  client: large,
  locations: [hq],
  reports_to: fin_dir,
  name: "Pablo Núñez",
  job_position: "Analista de Costos",
  work_area: "Finanzas",
  email: "pablo.nunez@demo20.prela",
  phone: "11-5000-2007"
)

seed_contact!(
  client: large,
  locations: [hq, north],
  reports_to: hr_dir,
  name: "Lucía Ferreyra",
  job_position: "Analista de RRHH",
  work_area: "Recursos Humanos",
  email: "lucia.ferreyra@demo20.prela",
  phone: "11-5000-2008",
  description: "Soporta Casa Central y Planta Norte"
)

seed_contact!(
  client: large,
  locations: [north],
  reports_to: north_mgr,
  name: "Tomás Ibarra",
  job_position: "Supervisor de turno",
  work_area: "Producción",
  email: "tomas.ibarra@demo20.prela",
  phone: "11-5000-2102"
)

seed_contact!(
  client: large,
  locations: [north],
  reports_to: north_mgr,
  name: "Nadia Pereyra",
  job_position: "Supervisora de calidad",
  work_area: "Calidad",
  email: "nadia.pereyra@demo20.prela",
  phone: "11-5000-2103"
)

seed_contact!(
  client: large,
  locations: [north],
  reports_to: north_mgr,
  name: "Bruno Salas",
  job_position: "Técnico electricista",
  work_area: "Mantenimiento",
  email: "bruno.salas@demo20.prela",
  phone: "11-5000-2104"
)

seed_contact!(
  client: large,
  locations: [south],
  reports_to: south_mgr,
  name: "Camila Duarte",
  job_position: "Supervisora de turno",
  work_area: "Producción",
  email: "camila.duarte@demo20.prela",
  phone: "11-5000-2202"
)

seed_contact!(
  client: large,
  locations: [south],
  reports_to: south_mgr,
  name: "Federico López",
  job_position: "Técnico mecánico",
  work_area: "Mantenimiento",
  email: "federico.lopez@demo20.prela",
  phone: "11-5000-2203"
)

seed_contact!(
  client: large,
  locations: [south],
  reports_to: south_mgr,
  name: "Agustina Roldán",
  job_position: "Analista de calidad",
  work_area: "Calidad",
  email: "agustina.roldan@demo20.prela",
  phone: "11-5000-2204"
)

seed_contact!(
  client: large,
  locations: [hq, north, south],
  reports_to: maint_coord,
  name: "Nicolás Benítez",
  job_position: "Técnico UPS",
  work_area: "Mantenimiento",
  email: "nicolas.benitez@demo20.prela",
  phone: "11-5000-2009",
  description: "Referente técnico UPS itinerante entre sedes"
)

seed_contact!(
  client: large,
  locations: [hq],
  reports_to: maint_coord,
  name: "Romina Aguirre",
  job_position: "Técnica de tableros",
  work_area: "Mantenimiento",
  email: "romina.aguirre@demo20.prela",
  phone: "11-5000-2010"
)

seed_contact!(
  client: large,
  locations: [north, south],
  reports_to: maint_coord,
  name: "Sebastián Ponce",
  job_position: "Técnico de campo",
  work_area: "Mantenimiento",
  email: "sebastian.ponce@demo20.prela",
  phone: "11-5000-2110",
  description: "Cubre Planta Norte y Planta Sur"
)

seed_contact!(
  client: large,
  locations: [south],
  reports_to: maint_coord,
  name: "Florencia Medina",
  job_position: "Técnica de campo",
  work_area: "Mantenimiento",
  email: "florencia.medina@demo20.prela",
  phone: "11-5000-2210"
)

# Disconnected plant contact: boss not in system, aligned mid-chart
seed_contact!(
  client: large,
  locations: [north, south],
  distance_above: 2,
  name: "Omar Villalba",
  job_position: "Jefe de Seguridad e Higiene",
  work_area: "EHS",
  email: "omar.villalba@demo20.prela",
  phone: "11-5000-2111",
  description: "Raíz desconectada; EHS en ambas plantas"
)

seed_contact!(
  client: large,
  locations: [north],
  distance_above: 3,
  name: "Inés Cabrera",
  job_position: "Auditora interna",
  work_area: "Calidad",
  email: "ines.cabrera@demo20.prela",
  phone: "11-5000-2112",
  description: "Raíz desconectada más abajo (distance_above: 3)"
)

puts "  Demo Org 20: #{large.contacts.kept.count} contacts, #{large.locations.kept.count} locations"

puts "Done. Open clients 'Demo Org 5' and 'Demo Org 20'."
puts "Look for multi-sede contacts (e.g. Gerente General, Coordinador de Mantenimiento)"
puts "and distance_above spacers: disconnected roots and gaps under Operaciones."

def ensure_supply_kind!(name, description:)
  kind = SupplyKind.kept.find_by(normalized_name: SupplyKind.normalize_name(name)) || SupplyKind.new
  kind.update!(name:, description:)
  kind
end

def ensure_supply!(kind, name, description:, reference_url: nil)
  supply = Supply.kept.find_by(normalized_name: Supply.normalize_name(name)) || Supply.new
  supply.update!(supply_kind: kind, name:, description:, reference_url:)
  supply
end

puts "Seeding supplies..."

kinds = {
  "Batería" => ensure_supply_kind!("Batería", description: "Baterías de UPS y arranque"),
  "Aceite" => ensure_supply_kind!("Aceite", description: "Lubricantes de motor, hidráulicos y de compresor"),
  "Correa" => ensure_supply_kind!("Correa", description: "Correas de transmisión"),
  "Filtro" => ensure_supply_kind!("Filtro", description: "Filtros de aceite, aire y combustible"),
  "Fusible" => ensure_supply_kind!("Fusible", description: "Fusibles de protección")
}

supplies = [
  ["Batería", "BP5-12", "12 V, 5 Ah", "https://example.com/bp5-12"],
  ["Batería", "BP7-12", "12 V, 7 Ah", "https://example.com/bp7-12"],
  ["Batería", "BP12-12", "12 V, 12 Ah", "https://example.com/bp12-12"],
  ["Batería", "CSB GP1272", "12 V, 7.2 Ah", "https://example.com/gp1272"],
  ["Batería", "Yuasa NP7-12", "12 V, 7 Ah", nil],
  ["Aceite", "Aceite 15W40", "Aceite de motor mineral", "https://example.com/15w40"],
  ["Aceite", "Aceite 10W30", "Aceite de motor sintético", "https://example.com/10w30"],
  ["Aceite", "Aceite hidráulico ISO 68", "Para sistemas hidráulicos", nil],
  ["Aceite", "Aceite para compresor", "Lubricante de compresores de aire", nil],
  ["Correa", "Correa A-42", "Correa clásica perfil A, 42 pulgadas", nil],
  ["Correa", "Correa A-44", "Correa clásica perfil A, 44 pulgadas", nil],
  ["Correa", "Correa B-60", "Correa clásica perfil B, 60 pulgadas", nil],
  ["Correa", "Correa 5PK1130", "Correa poly-V de accesorios", "https://example.com/5pk1130"],
  ["Filtro", "Filtro de aceite", "Filtro de aceite de motor", nil],
  ["Filtro", "Filtro de aire", "Filtro de admisión", nil],
  ["Filtro", "Filtro de combustible", "Filtro de gasoil", nil],
  ["Filtro", "Filtro de cabina", "Filtro de habitáculo", nil],
  ["Fusible", "Fusible 10 A", "Fusible de cuchilla 10 A", nil],
  ["Fusible", "Fusible 20 A", "Fusible de cuchilla 20 A", nil],
  ["Fusible", "Fusible 32 A", "Fusible de cuchilla 32 A", nil]
]

supplies.each do |kind_name, name, description, reference_url|
  ensure_supply!(kinds.fetch(kind_name), name, description:, reference_url:)
end

{
  "BP5-12" => ["BP7-12", "CSB GP1272"],
  "BP7-12" => ["Yuasa NP7-12"],
  "Aceite 15W40" => ["Aceite 10W30"],
  "Correa A-42" => ["Correa A-44"]
}.each do |name, partner_names|
  supply = Supply.kept.find_by!(normalized_name: Supply.normalize_name(name))
  partner_ids = partner_names.map { |partner_name|
    Supply.kept.find_by!(normalized_name: Supply.normalize_name(partner_name)).id
  }
  supply.update!(replacement_ids: partner_ids)
end

puts "  #{SupplyKind.kept.count} supply kinds, #{Supply.kept.count} supplies"
puts "Open Insumos → Lista. The catalog has more than one page."
