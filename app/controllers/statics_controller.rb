class StaticsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]

  def index
  end

  def home
    # binding.pry
    current_user.roles.map{|r|r.nick}.include?("admin")
    # @indent = Indent.find(user_id: current_user)
  end
end
