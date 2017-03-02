class BaseService
  cattr_accessor :user
  # "重写" Devise 的 current_user 方法( Devise 的方法只能在 Controller 中使用)
  def self.current_user
    user
  end
end
