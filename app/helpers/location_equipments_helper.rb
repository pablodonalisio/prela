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
end
