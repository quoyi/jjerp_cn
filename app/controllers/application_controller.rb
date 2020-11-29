class ApplicationController < ActionController::Base
  # layout :layout_by_validity
  # 添加flash消息类型
  add_flash_types :warning, :error
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_with_term!
  # before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # enable_authorization :unless => :devise_controller?

  # 重写用户登陆成功后跳转路径
  def after_sign_in_path_for(_resource)
    BaseService.user = current_user
    valid_term? ? home_path : root_path
  end

  # def after_sign_up_path_for(resource)
  #   redirect_to user_profile_path
  # end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:name, :email, :password, :password_confirmation, :current_password)
    end
  end

  def authenticate_with_term!
    return redirect_to(expired_url) if Date.today > Date.new(2028, 1, 15)

    authenticate_user!
  end
end
