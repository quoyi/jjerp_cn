class Role < ActiveRecord::Base
  
  ADMINISTRATOR = 'super_admin'.freeze

  has_and_belongs_to_many :users, :join_table => :user_roles
  has_many :role_permissions
  accepts_nested_attributes_for :role_permissions, allow_destroy: true
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :nick
  validates_uniqueness_of :nick


  @@permissions = {}
  cattr_reader :permissions

  def self.register_permission(hash)
    klass = hash.delete(:class)
    # require 'pry'
    # binding.pry
    klass.constantize.rescue_from Account::PermissionDenied do |exception|
      redirect_to root_path, notice: '没有访问权限'
    end

    klass.constantize.before_action do
      current_user.permit!(self.class, action_name)
    end

    @@permissions[klass] ||= {}
    @@permissions[klass][:name] = hash[:name]
    @@permissions[klass][:actions] = hash[:actions]
  end

  def permission?(klass, action)
    role_permissions.detect { |r| r.permission?(klass, action) }
  end

  def editable?
    nick != ADMINISTRATOR
  end

end
