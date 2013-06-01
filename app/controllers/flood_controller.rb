class FloodController < ApplicationController
  def index
  end

  def find
    loc = {lat: params[:latitude], long: params[:longitude]}
    zone = FloodZone.get_zone_at_coordinates loc[:lat], loc[:long]
    zone_designation = FloodDesignation[zone['name']]
    respond_to do |f|
      f.json { render json: {
        loc: loc, 
        zone: zone, 
        zone_designation: zone_designation
        }}
    end
  end
end
