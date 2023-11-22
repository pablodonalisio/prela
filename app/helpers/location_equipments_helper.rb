module LocationEquipmentsHelper
  def humanize_floor(floor)
    return unless floor

    if floor < -1
      "Subsuelo #{floor.abs}"
    elsif floor.eql?(-1)
      "Subsuelo"
    elsif floor.eql?(0)
      "PB"
    else
      floor
    end
  end

  def service_date_color(date)
    return unless date

    if date < Date.today.months_since(1)
      "text-danger"
    elsif date < Date.today.months_since(3)
      "text-warning"
    else
      "text-success"
    end
  end
end
