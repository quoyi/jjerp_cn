module OffersHelper
  # 生成指定 indent 的报价单
  def create_offer(indent)
    binding.pry
    orders = indent.orders
    # 开启事务，报价单生成要么成功，要么失败。成功时，才删除之前的报价记录。
    ActiveRecord::Base.transaction do
      # 先删除已存在的报价单
      indent.offers.destroy_all
      # 计算各个子订单的部件、配件、工艺价格（即生成报价单）
      orders.each do |order|
        order.units.each do |unit|
          material = Material.find_by(ply: unit.ply, texture: (unit.texture || order.texture), color: (unit.color || order.color))
          unless material
            # indent.offers.destroy_all
            return '未查到"基础数据——板料"中未找到对应板料，请联系管理员添加！'
          end
          offer = Offer.find_or_create_by(item_id: material.id, item_type: material.class, indent_id: indent.id, order_id: order.id)
          offer.price = material.price.to_f
          size = unit.size.split(/[xX*]/).map(&:to_i)
          offer.number = offer.number.to_f + ((unit.number.to_f * size[0] * size[1])/(1000*1000))
          offer.total = offer.price * offer.number
          # mc_ids = [material.ply, material.texture, material.face, material.color]
          # offer.item_name = MaterialCategory.where(id: mc_ids).map(&:name).join("-")
          offer.item_name = [MaterialCategory.find(material.ply).name, MaterialCategory.find(material.texture).name,  MaterialCategory.find(material.color).name].join('-')
          offer.item_type = material.class
          offer.save!
        end

        order.parts.each do |op|
          part = op.part
          offer_p = Offer.find_or_create_by(item_id: part.id, item_type: part.class, indent_id: indent.id, order_id: order.id)
          offer_p.number = offer_p.number.to_i + order_part.number.to_i
          offer_p.price = part.sell.to_f
          offer_p.total = offer_p.price * offer_p.number
          offer_p.item_name = part.name
          offer_p.category = part.part_category.name
          offer_p.save!
        end

        order.crafts.each do |craft|
          p = Offer.find_or_create_by(item_id: craft.id, item_type: craft.class, indent_id: indent.id, order_id: order.id)
          p.number = p.number.to_i + craft.number.to_i
          p.price = craft.price
          p.total = p.price * p.number
          p.item_name = craft.item
          p.save!
        end
        order.offered!
        order.save!
      end
    end
    indent.offered!
    binding.pry
    return '报价成功！'
  end
end
