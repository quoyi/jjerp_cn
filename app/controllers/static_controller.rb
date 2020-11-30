class StaticController < ApplicationController
  skip_before_action :authenticate_with_term!

  # GET / 首页
  def index
    redirect_to dashboard_path if current_user
  end

  # GET /about 关于
  # def about
  # end

  # GET /contact 联系我们
  # def contact
  # end

  # GET /terms 服务条款
  def terms
  end

  # GET /privacy 隐私政策
  def privacy
  end

  # GET /expired 授权过期
  def expired
  end

  # GET /home 个人主页
  # def home
  #   # current_user.roles.map{|r|r.nick}.include?("admin")
  #   # @indents = Indent.where(agent_id: current_user.id)
  # end
end
