class RolePermission < ActiveRecord::Base
  belongs_to :role
  def permission?(klass, action)
    if action
      if %w[index show new create update edit destroy].include?(action.to_s)
        self.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
      else
        true
      end
    else
      self.klass == klass.to_s
    end
  end
end

# == Schema Information
#
# Table name: role_permissions
#
#  id            :integer          not null, primary key
#  actions       :string(255)      not null
#  klass         :string(255)      not null
#  note          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  permission_id :integer
#  role_id       :integer
#
# Indexes
#
#  index_role_permissions_on_permission_id  (permission_id)
#  index_role_permissions_on_role_id        (role_id)
#
