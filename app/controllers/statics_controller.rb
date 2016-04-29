class StaticsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def home
    @indent = Indent.find_by(user_id: current_user)
  end
end
