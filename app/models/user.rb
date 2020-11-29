class User < ApplicationRecord
  has_and_belongs_to_many :roles, join_table: :user_roles
  # 引入 devise 默认模块 :database_authenticatable, :registerable, :confirmable, :recoverable,
  #  :rememberable, :trackable, :validatable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  attr_accessor :material_number, :amount, :order_number

  # attr_accessor :email, :password, :password_confirmation
  # validates_presence_of :email, :password, :password_confirmation
  # validates :email, format: {with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }
  # validates_length_of :password, within: 6..30, allow_blank: true
  # validates_length_of :password_confirmation, within: 6..30, allow_blank: true
  # 删除开始
  # after_save :assign_role
  # def assign_role
  #   # add_role("other") if self.role.nil?
  #   self.roles << Role.find_by_nick("other") if self.roles.nil?
  # end

  def roles?(nick)
    # self.roles.exists?(nick: nick)
    # roles.any? { |r| r.nick.underscore.to_sym == role_sym }
    roles.pluck(:nick).include?(nick)
  end

  # def append_role(nick)
  #   return true if roles?(nick)
  #   role = Role.find_by_nick(nick)
  #   return false unless role
  #   self.roles << role
  # end

  # def has_permission?(klass, action)
  #   return true if roles.find {|r| r.nick == Role::ADMINISTRATOR }
  #   self.roles.permissions.detect do |p|
  #     if action
  #       p.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
  #     else
  #       self.klass == klass.to_s
  #     end
  #   end

  #   # return true if roles.find {|r| r.nick == Role::ADMINISTRATOR }
  #   # roles.find {|r| r.has_permission?(klass, action)}
  # end
  # 删除结束

  after_save :add_normal_role

  def role?(role_name)
    roles.exists?(nick: role_name)
  end

  def admin?
    role?('super_admin') || role?('admin')
  end

  def add_role!(role_nick)
    return true if role?(role_nick)

    role = Role.find_by_nick(role_nick)
    return false unless role

    roles << role
  end

  def permission?(klass, action)
    return true if roles.find { |r| r.nick == Role::ADMINISTRATOR }

    roles.find { |r| r.permission?(klass, action) }
  end

  def permit!(klass, action)
    raise Account::PermissionDenied unless permission?(klass, action)
  end

  def add_normal_role
    add_role!('normal')
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  cert                   :string(255)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  deleted                :boolean          default(FALSE), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  mobile                 :string(255)      default(""), not null
#  name                   :string(255)
#  print_size             :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0), not null
#  user_category          :integer          default(0), not null
#  username               :string(255)      default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_mobile                (mobile)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username)
#
