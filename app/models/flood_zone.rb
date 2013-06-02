class FloodZone
  def self.get_zone_at_coordinates(lat, long)
    get_at_coordinates lat, long, 'femafloodzone_lyr'
  end

  private
  def self.get_at_coordinates(lat, long, table)
    escaped_lat = Float(lat).to_s
    escaped_long = Float(long).to_s

    query = <<-SQL
      SELECT ogc_fid, name
      FROM #{table}
      WHERE ST_Within(ST_PointFromText('POINT(#{escaped_long} #{escaped_lat})', 4326), wkb_geometry)
      LIMIT 5;
    SQL

    ActiveRecord::Base.connection.select_one query
  end
end
