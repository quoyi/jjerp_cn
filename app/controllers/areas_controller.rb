class AreasController < ApplicationController
  # skip_before_action :authenticate_user!

  def find
    if params[:pid].present?
      @result = City.where(province_id: params[:pid]).order(:id)
    elsif params[:cid].present?
      @result = District.where(city_id: params[:cid]).order(:id)
    end
    render json: @result
  end
end
