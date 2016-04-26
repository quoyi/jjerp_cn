class User < ActiveRecord::Base
  # 引入 devise 默认模块 :database_authenticatable, :registerable, :confirmable, :recoverable,
  #  :rememberable, :trackable, :validatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # validates_presence_of :email, :password, :remember_created_at
  # validates_presence_of :password_confirmation, on: :create
  # validates_uniqueness_of :email
  # attr_accessor :email, :password, :password_confirmation
end
