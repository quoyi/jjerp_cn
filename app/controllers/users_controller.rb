class UsersController < ApplicationController
  # skip_before_action :authenticate_user!
  before_action :set_current_user, only: [:edit, :update]

  def index
    params[:start_at] ||= Date.today.beginning_of_month
    params[:end_at] ||= Date.today.end_of_month
    @users = User.all
    @users.each do |user|
      orders = Order.where('handler = ? and (created_at between ? and ?)',
                           user.id,
                           params[:start_at].to_datetime.beginning_of_day,
                           params[:end_at].to_datetime.end_of_day)
      material_number = 0
      amount = 0
      orders.each do |order|
        order.units.each do |unit|
          unless unit.is_backboard?
            if unit.size.blank?
              material_number += unit.number
            else
              material_number += unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result *= item } / (1000 * 1000).to_f * unit.number
            end
          end
        end
        amount += order.price
      end
      user.material_number = material_number
      user.amount = amount
      user.order_number = orders.size
    end
    # respond_to do |format|
    #   format.html { @users = @users.page(params[:page]).per(1) }
    # end
  end

  def edit
    if update_permission?
      redirect_to statics_home_path, error: '没有权限访问该页面！' 
    else
      @role = @user.roles.first
    end
  end

  def profile
    @user = User.find_by(id: params[:user_id]) if params[:user_id].present?
    redirect_to statics_home_path, error: '没有权限访问该页面！' if update_permission?
  end

  def update
    # 管理员更新用户角色
    if update_permission? && user_params[:role_ids]
      @user.roles.delete(@user.roles.first) if @user.roles.any?
      @role = Role.find(user_params[:role_ids].to_i)
      @user.add_role! @role.nick
      flash[:success] = "用户#{@user.username}角色已改为#{@role.name}!"
    end
    # 用户修改自己的账号信息
    if update_permission? && @user.update(user_params)
      @role = @user.roles.first
      flash[:success] = '您的信息已修改！'
    else
      flash[:error] = '个人信息修改失败！'
    end
    redirect_to :back
  end

  private

    def set_current_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:id, :role_ids, :name, :email, :username, :mobile, :start_at, :end_at)
    end

    def change_role
      Role.find(params[:user][:role_ids].to_i) unless params[:user][:role_ids].blank?
    end

    def update_permission?
      current_user.id != @user.id && !current_user.has_role?('super_admin') && !current_user.has_role?('admin')
    end
end
