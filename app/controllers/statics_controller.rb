class StaticsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]

  def index
    redirect_to statics_home_path if current_user
  end

  def home
    # current_user.roles.map{|r|r.nick}.include?("admin")
    @indents = Indent.where(agent_id: 1)
  end
end
