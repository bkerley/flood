class Rainfall
  attr_accessor :distance, :amount, :unit

  def inverse_distance
    1.0 / distance
  end

  def weighted_amount
    amount * inverse_distance
  end

  def self.unweight(coll)
    all_inverse_distance = coll.map(&:inverse_distance).inject(:+)
    all_amount = coll.map(&:weighted_amount).inject(:+)

    all_amount / all_inverse_distance
  end

  def as_json(opts={})
    {distance: distance, amount: amount, unit: unit}
  end

  def self.measurements_near(lat, long)
    escaped_lat = Float(lat).to_s
    escaped_long = Float(long).to_s
    dist_calculation = <<-SQL
      ST_Distance(wkb_geometry, 
            ST_PointFromText(
              'POINT(#{escaped_long} #{escaped_lat})',
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
      ORDER BY 
        #{dist_calculation} ASC
      LIMIT 5;
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
