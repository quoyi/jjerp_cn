# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  klass      :string(255)      not null
#  actions    :string(255)      not null
#  note       :string(255)
#  deleted    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
