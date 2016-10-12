class RolePermission < ActiveRecord::Base
  belongs_to :role
  def permission?(klass, action)
      if action
        if ["index", "show", "new", "create", "update", "edit", "destroy"].include?(action.to_s)
          self.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
        else
          return true
        end
      else
        self.klass == klass.to_s
      end
  end
end
