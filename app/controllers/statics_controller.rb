class StaticsController < ApplicationController
  skip_before_action :authenticate!, only: [:index]

  def index
    redirect_to statics_home_path if current_user
  end

  def home
    # current_user.roles.map{|r|r.nick}.include?("admin")
    
    # @indents = Indent.where(agent_id: current_user.id)
  end

  def about
    redirect_to statics_home_path if Date.today < Date.new(2017, 1, 1)
  end
end
