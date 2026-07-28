# Demo clients with contact org charts for local UI review.
# Safe to re-run: rebuilds contacts for these two demo clients only.

def seed_contact!(client:, location: nil, reports_to: nil, **attrs)
  client.contacts.create!(
    location:,
    reports_to:,
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

ceo = seed_contact!(
  client: small,
  location: small_hq,
  name: "Laura Méndez",
  job_position: "Directora General",
  work_area: "Dirección",
  email: "laura.mendez@demo5.prela",
  phone: "11-4000-1001",
  description: "Contacto principal del cliente"
)

ops = seed_contact!(
  client: small,
  location: small_hq,
  reports_to: ceo,
  name: "Martín Rivas",
  job_position: "Jefe de Operaciones",
  work_area: "Operaciones",
  email: "martin.rivas@demo5.prela",
  phone: "11-4000-1002"
)

seed_contact!(
  client: small,
  location: small_hq,
  reports_to: ops,
  name: "Sofía Acosta",
  job_position: "Técnica senior",
  work_area: "Mantenimiento",
  email: "sofia.acosta@demo5.prela",
  phone: "11-4000-1003"
)

seed_contact!(
  client: small,
  location: small_hq,
  reports_to: ops,
  name: "Diego Farías",
  job_position: "Técnico",
  work_area: "Mantenimiento",
  email: "diego.farias@demo5.prela",
  phone: "11-4000-1004"
)

seed_contact!(
  client: small,
  location: small_hq,
  reports_to: ceo,
  name: "Valentina Ruiz",
  job_position: "Administrativa",
  work_area: "Administración",
  email: "valentina.ruiz@demo5.prela",
  phone: "11-4000-1005"
)

puts "  Demo Org 5: #{small.contacts.kept.count} contacts"

# --- 20-person org ----------------------------------------------------------
large = Client.find_or_create_by!(name: "Demo Org 20")
reset_demo_contacts!(large)

hq = ensure_location!(large, "Casa Central")
north = ensure_location!(large, "Planta Norte")
south = ensure_location!(large, "Planta Sur")

gm = seed_contact!(
  client: large,
  location: hq,
  name: "Ricardo Peña",
  job_position: "Gerente General",
  work_area: "Dirección",
  email: "ricardo.pena@demo20.prela",
  phone: "11-5000-2001",
  description: "Decisiones comerciales y de contrato"
)

ops_dir = seed_contact!(
  client: large,
  location: hq,
  reports_to: gm,
  name: "Carolina Vázquez",
  job_position: "Directora de Operaciones",
  work_area: "Operaciones",
  email: "carolina.vazquez@demo20.prela",
  phone: "11-5000-2002"
)

fin_dir = seed_contact!(
  client: large,
  location: hq,
  reports_to: gm,
  name: "Andrés Molina",
  job_position: "Director de Finanzas",
  work_area: "Finanzas",
  email: "andres.molina@demo20.prela",
  phone: "11-5000-2003"
)

hr_dir = seed_contact!(
  client: large,
  location: hq,
  reports_to: gm,
  name: "Patricia Gómez",
  job_position: "Directora de RRHH",
  work_area: "Recursos Humanos",
  email: "patricia.gomez@demo20.prela",
  phone: "11-5000-2004"
)

north_mgr = seed_contact!(
  client: large,
  location: north,
  reports_to: ops_dir,
  name: "Julián Castro",
  job_position: "Jefe de Planta Norte",
  work_area: "Operaciones",
  email: "julian.castro@demo20.prela",
  phone: "11-5000-2101"
)

south_mgr = seed_contact!(
  client: large,
  location: south,
  reports_to: ops_dir,
  name: "Elena Quiroga",
  job_position: "Jefa de Planta Sur",
  work_area: "Operaciones",
  email: "elena.quiroga@demo20.prela",
  phone: "11-5000-2201"
)

maint_coord = seed_contact!(
  client: large,
  location: hq,
  reports_to: ops_dir,
  name: "Héctor Blanco",
  job_position: "Coordinador de Mantenimiento",
  work_area: "Mantenimiento",
  email: "hector.blanco@demo20.prela",
  phone: "11-5000-2005"
)

seed_contact!(
  client: large,
  location: hq,
  reports_to: fin_dir,
  name: "Marina Ortega",
  job_position: "Analista de Cuentas",
  work_area: "Finanzas",
  email: "marina.ortega@demo20.prela",
  phone: "11-5000-2006"
)

seed_contact!(
  client: large,
  location: hq,
  reports_to: fin_dir,
  name: "Pablo Núñez",
  job_position: "Analista de Costos",
  work_area: "Finanzas",
  email: "pablo.nunez@demo20.prela",
  phone: "11-5000-2007"
)

seed_contact!(
  client: large,
  location: hq,
  reports_to: hr_dir,
  name: "Lucía Ferreyra",
  job_position: "Analista de RRHH",
  work_area: "Recursos Humanos",
  email: "lucia.ferreyra@demo20.prela",
  phone: "11-5000-2008"
)

seed_contact!(
  client: large,
  location: north,
  reports_to: north_mgr,
  name: "Tomás Ibarra",
  job_position: "Supervisor de turno",
  work_area: "Producción",
  email: "tomas.ibarra@demo20.prela",
  phone: "11-5000-2102"
)

seed_contact!(
  client: large,
  location: north,
  reports_to: north_mgr,
  name: "Nadia Pereyra",
  job_position: "Supervisora de calidad",
  work_area: "Calidad",
  email: "nadia.pereyra@demo20.prela",
  phone: "11-5000-2103"
)

seed_contact!(
  client: large,
  location: north,
  reports_to: north_mgr,
  name: "Bruno Salas",
  job_position: "Técnico electricista",
  work_area: "Mantenimiento",
  email: "bruno.salas@demo20.prela",
  phone: "11-5000-2104"
)

seed_contact!(
  client: large,
  location: south,
  reports_to: south_mgr,
  name: "Camila Duarte",
  job_position: "Supervisora de turno",
  work_area: "Producción",
  email: "camila.duarte@demo20.prela",
  phone: "11-5000-2202"
)

seed_contact!(
  client: large,
  location: south,
  reports_to: south_mgr,
  name: "Federico López",
  job_position: "Técnico mecánico",
  work_area: "Mantenimiento",
  email: "federico.lopez@demo20.prela",
  phone: "11-5000-2203"
)

seed_contact!(
  client: large,
  location: south,
  reports_to: south_mgr,
  name: "Agustina Roldán",
  job_position: "Analista de calidad",
  work_area: "Calidad",
  email: "agustina.roldan@demo20.prela",
  phone: "11-5000-2204"
)

seed_contact!(
  client: large,
  location: hq,
  reports_to: maint_coord,
  name: "Nicolás Benítez",
  job_position: "Técnico UPS",
  work_area: "Mantenimiento",
  email: "nicolas.benitez@demo20.prela",
  phone: "11-5000-2009",
  description: "Referente técnico para equipos UPS"
)

seed_contact!(
  client: large,
  location: hq,
  reports_to: maint_coord,
  name: "Romina Aguirre",
  job_position: "Técnica de tableros",
  work_area: "Mantenimiento",
  email: "romina.aguirre@demo20.prela",
  phone: "11-5000-2010"
)

seed_contact!(
  client: large,
  location: north,
  reports_to: maint_coord,
  name: "Sebastián Ponce",
  job_position: "Técnico de campo",
  work_area: "Mantenimiento",
  email: "sebastian.ponce@demo20.prela",
  phone: "11-5000-2110"
)

seed_contact!(
  client: large,
  location: south,
  reports_to: maint_coord,
  name: "Florencia Medina",
  job_position: "Técnica de campo",
  work_area: "Mantenimiento",
  email: "florencia.medina@demo20.prela",
  phone: "11-5000-2210"
)

puts "  Demo Org 20: #{large.contacts.kept.count} contacts"
puts "Done. Open clients 'Demo Org 5' and 'Demo Org 20'."
