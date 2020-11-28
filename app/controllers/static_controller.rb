class StaticController < ApplicationController
  skip_before_action :authenticate!, except: [:home]

  # GET /
  def index
    redirect_to home_path if current_user
  end

  # GET /about
  def about
  end

  # GET /contact
  def contact
  end

  # GET /home
  def home
    # current_user.roles.map{|r|r.nick}.include?("admin")
    # @indents = Indent.where(agent_id: current_user.id)
  end
end
