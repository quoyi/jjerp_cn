class Material < ActiveRecord::Base
  belongs_to :material_category
  validates_presence_of :serial, :name, :ply, :texture, :color, :buy, :sell, :supply_id
  before_create :generate_order_code

  # 生成编码
  def generate_order_code
    begin
      self.serial = "" + (orders_count+1).to_s
      self.work_id = 1
    end while self.class.exists?(:name => name)
  end
end
