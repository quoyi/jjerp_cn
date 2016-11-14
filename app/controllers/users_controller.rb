class UsersController < ApplicationController
  before_action :set_current_user, only: [:edit, :update]

  def index
    @users = User.all
  end

  def edit
  end

  def update
    if @user.update(user_params)
      @user.roles.delete(@user.roles.first) if @user.roles.any?
      @user.add_role! change_role.nick if change_role
      flash[:notice] = '用户修改成功.'
    else
      flash[:alert] = '修改过程中出现错误'
    end
    redirect_to edit_user_path(@user)
  end

  private
    def set_current_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role_ids, :name, :email, :username, :mobile)
    end

    def change_role
      Role.find(params[:user][:role_ids].to_i) unless params[:user][:role_ids].blank?
    end


end