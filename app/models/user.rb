class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, join_table: :user_roles
  # 引入 devise 默认模块 :database_authenticatable, :registerable, :confirmable, :recoverable,
  #  :rememberable, :trackable, :validatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  # attr_accessor :email, :password, :password_confirmation
  # validates_presence_of :email, :password, :password_confirmation
  # validates :email, format: {with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }
  # validates_length_of :password, within: 6..30, allow_blank: true
  # validates_length_of :password_confirmation, within: 6..30, allow_blank: true


  def role?(r)
    roles.exists?(alias: r)
  end

  def add_role!(r)
    return true if role?(r)
    role = Role.find_by_alias(r)
    return false unless role
    roles << role
  end
end
