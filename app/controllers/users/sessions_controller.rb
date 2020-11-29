# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # layout 'users'

  respond_to :html, :js
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(sign_in_params)

    if resource&.active_for_authentication?
      sign_in_and_redirect(resource_name, resource)
    else
      self.resource = resource_class.new(sign_in_params)
      # clean_up_passwords(resource)
      resource.errors.add(:base, '账号或密码错误！')
      render :new
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in) do |user_params|
  #     user_params.permit(:email, :password, :remember_me)
  #   end
  # end
end
