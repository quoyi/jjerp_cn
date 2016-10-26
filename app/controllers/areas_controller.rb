class AreasController < ApplicationController
  # skip_before_action :authenticate_user!
  
  def find
    if params[:pid].present?
      @result = City.where(province_id: params[:pid])
    elsif params[:cid].present?
      @result = District.where(city_id: params[:cid])
    end
    render json: @result
  end
end
