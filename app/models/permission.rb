class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles, join_table: :role_permissions

  def has_permission?(klass, action)
    if action
      self.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
    else
      self.klass == klass.to_s
    end
  end
end
