class Role < ActiveRecord::Base
  # 冻结常量 ADMINISTRATOR 防止被修改
  ADMINISTRATOR = 'super_admin'.freeze
  has_and_belongs_to_many :users, join_table: :user_roles
  has_and_belongs_to_many :permissions, join_table: :role_permissions
  has_many :role_permissions
  accepts_nested_attributes_for :role_permissions, allow_destroy: true
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :nick
  validates_uniqueness_of :nick

  @permissions = {}

  cattr_reader :permissions

  def self.register_permission(hash)
    klass = hash.delete(:class)
    klass.constantize.rescue_from Account::PermissionDenied do |_exception|
      redirect_to :back, error: '没有访问权限'
    end

    klass.constantize.before_action do
      current_user.permit!(self.class, action_name)
    end

    @permissions[klass] ||= {}
    @permissions[klass][:name] = hash[:name]
    @permissions[klass][:actions] = hash[:actions]
  end

  def permission?(klass, action)
    role_permissions.detect { |r| r.permission?(klass, action) }
  end

  def editable?
    nick != ADMINISTRATOR
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  deleted    :boolean          default(FALSE), not null
#  display    :boolean          default(TRUE), not null
#  name       :string(255)      not null
#  nick       :string(255)
#  note       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name)
#
