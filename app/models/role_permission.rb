class RolePermission < ActiveRecord::Base
  belongs_to :role
  def permission?(klass, action)
      if action
        self.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
      else
        self.klass == klass.to_s
      end
  end
end
