module CompanyInfo
  module_function

  def name
    "Prela"
  end

  def emergency_phone
    "3515 63-4165"
  end

  def emergency_phone_label
    "Emergencias 24/7"
  end

  def admin_phone
    "3512 95-1497"
  end

  def admin_phone_label
    "Administración 9 a 17hs"
  end

  def email
    "contacto@prela.com.ar"
  end

  def address
    "Hualfin 758 - Córdoba"
  end

  def maps_url
    "https://www.google.com/maps/search/?api=1&query=#{ERB::Util.url_encode(address)}"
  end

  def footer_lines
    [
      "#{emergency_phone_label}: #{emergency_phone}",
      "#{admin_phone_label}: #{admin_phone}",
      "Email: #{email}",
      "Dir: #{address}"
    ]
  end

  def emergency_whatsapp_url
    whatsapp_url(emergency_phone)
  end

  def admin_whatsapp_url
    whatsapp_url(admin_phone)
  end

  def whatsapp_url(phone)
    digits = phone.to_s.gsub(/\D/, "")
    "https://wa.me/549#{digits}"
  end
end
