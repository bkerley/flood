class Rainfall
  attr_accessor :distance, :amount, :unit

  def inverse_distance
    1.0 / distance
  end

  def weighted_amount
    amount * inverse_distance
  end

  def self.unweight(coll)
    return 0 if coll.length == 0
    all_inverse_distance = coll.map(&:inverse_distance).inject(:+)
    all_amount = coll.map(&:weighted_amount).inject(:+)

    all_amount / all_inverse_distance
  end

  def as_json(opts={})
    {distance: distance, amount: amount, unit: unit}
  end

  def self.measurements_near(lat, long)
    lat = Float(lat)
    long = Float(long)
    dist_calculation = <<-SQL
      ST_Distance(wkb_geometry, 
            ST_PointFromText(
              'POINT(#{long} #{lat})',
               900914))
    SQL
    query = <<-SQL
      SELECT 
        ST_AsText(wkb_geometry), 
        #{dist_calculation},
        ogc_fid, 
        globvalue, 
        units 
      FROM nws_precip_1day_observed_20130601 
      WHERE
        lat > #{lat - 1} AND lat < #{lat + 1} AND
        lon > #{long - 1} AND lon < #{long + 1}
      ORDER BY 
        #{dist_calculation} ASC
      LIMIT 9;
    SQL

    measurements = ActiveRecord::Base.connection.
      select_all(query).
      map do |q|
        m = new
        m.distance = Float q['st_distance']
        m.amount = Float q['globvalue']
        m.unit = q['units']
        m
    end
  end
end
