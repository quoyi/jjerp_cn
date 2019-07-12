class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles, join_table: :role_permissions

  def permission?(klass, action)
    if action
      self.klass == klass.to_s && actions.to_s.split(',').include?(action.to_s)
    else
      self.klass == klass.to_s
    end
  end
end

# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  actions    :string(255)      not null
#  deleted    :boolean          default(FALSE), not null
#  klass      :string(255)      not null
#  name       :string(255)
#  note       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
