module OffersHelper
  # 生成指定 indent 的报价单
  def create_offer(indent)
    orders = indent.orders
    # 开启事务，报价单生成要么成功，要么失败。成功时，才删除之前的报价记录。
    ActiveRecord::Base.transaction do
      # 1.删除之前的报价单
      indent.offers.destroy_all
      # 2.进行新报价逻辑
      orders.each do |order|
        # 2.1 计算部件报价
        order.units.each do |unit|
          material = Material.find_by(ply: (order.ply || unit.ply), texture: (order.texture || unit.texture), color: (order.color || unit.color))
          if material
            offer = Offer.find_or_create_by(item_id: material.id, item_type: Offer.item_types[:unit], indent_id: indent.id, order_id: order.id)
            offer.price = material.price.to_f
            size = unit.size.split(/[xX*]/).map(&:to_i)
            offer.number = offer.number.to_f + ((unit.number.to_f * size[0] * size[1])/(1000*1000))
            offer.total = offer.price * offer.number
            # mc_ids = [material.ply, material.texture, material.face, material.color]
            # offer.item_name = MaterialCategory.where(id: mc_ids).map(&:name).join("-")
            offer.item_name = [MaterialCategory.find(material.ply).name, MaterialCategory.find(material.texture).name,  MaterialCategory.find(material.color).name].join('-')
            offer.item_type = Offer.item_types[:unit]
            offer.uom = '平方'
            offer.save!
          else
            msg = '未查到"基础数据——板料"中未找到对应板料，请联系管理员添加！'
          end
        end
        # 2.2 计算配件报价
        order.parts.each do |part|
        end
        # 2.3 计算工艺报价
        order.crafts.each do |craft|
        end
      end
    end
    indent.offered!
    binding.pry
    return '报价成功！'
  end
end
