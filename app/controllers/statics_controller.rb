class StaticsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def home
  end
end
