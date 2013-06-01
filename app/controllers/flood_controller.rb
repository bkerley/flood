class FloodController < ApplicationController
  def index
  end

  def find
    loc = {lat: params[:latitude], long: params[:longitude]}
    zone = FloodZone.get_zone_at_coordinates loc[:lat], loc[:long]
    zone_designation = FloodDesignation[zone['name']]
    rain_measures = Rainfall.measurements_near loc[:lat], loc[:long]
    rain_estimate = Rainfall.unweight rain_measures

    flooding = rain_estimate > 1

    respond_to do |f|
      f.json { render json: {
        loc: loc, 
        zone: zone, 
        zone_designation: zone_designation,
        rain_measures: rain_measures,
        rain_estimate: rain_estimate, 
        flooding: flooding,
        }}
    end
  end
end
