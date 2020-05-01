class MappingService
  def self.find_center_point(locations)
    number_of_locations = locations.length

    return locations.first if number_of_locations == 1

    x = y = z = 0.0
    locations.each do |station|
      latitude = station[:latitude] * Math::PI / 180
      longitude = station[:longitude] * Math::PI / 180

      x += Math.cos(latitude) * Math.cos(longitude)
      y += Math.cos(latitude) * Math.sin(longitude)
      z += Math.sin(latitude)
    end

    x = x/number_of_locations
    y = y/number_of_locations
    z = z/number_of_locations

    central_longitude =  Math.atan2(y, x)
    central_square_root = Math.sqrt(x * x + y * y)
    central_latitude = Math.atan2(z, central_square_root)

    {
      latitude: central_latitude * 180 / Math::PI,
      longitude: central_longitude * 180 / Math::PI
    }
  end
end