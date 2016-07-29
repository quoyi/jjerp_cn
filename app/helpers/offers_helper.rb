module OffersHelper
  # 生成指定 indent 的报价单
  def create_offer(indent)
    orders = indent.orders
    # 开启事务，报价单生成要么成功，要么失败。成功时，才删除之前的报价记录。
    ActiveRecord::Base.transaction do
      # 1.删除之前的报价单
      #indent.offers.destroy_all
      # 2.进行新报价逻辑
      orders.each do |order|
        # 删除之前的报价单
        order.offers.destroy_all
        # 2.1 计算部件报价
        order.units.each do |unit|
          material = Material.find_by(ply: unit.ply, texture: unit.texture, color: unit.color)
          # binding.pry
          # 导入的部件板料存在时，以部件的材质信息为准。否则，以订单的材质信息为准
          if material.present?
            offer = Offer.find_or_create_by(item_id: material.id, item_type: Offer.item_types[:unit],
                                            indent_id: indent.id, order_id: order.id, price: unit.price.to_f)
            # 如果 unit 价格 与标准价格不同，则新建一条 offer 记录
            offer.price = unit.price.to_f
            size = unit.size.split(/[xX*×]/).map(&:to_i)
            if size.present? && size.size == 2
              offer.number = offer.number.to_f + ((unit.number.to_f * size[0] * size[1])/(1000*1000))
            else
              offer.number = offer.number.to_f + unit.number.to_f
            end
            offer.total = offer.price * offer.number
            # mc_ids = [material.ply, material.texture, material.face, material.color]
            # offer.item_name = MaterialCategory.where(id: mc_ids).map(&:name).join("-")
            offer.item_name = [MaterialCategory.find(material.ply).name, MaterialCategory.find(material.texture).name,  MaterialCategory.find(material.color).name].join('-')
            offer.item_type = Offer.item_types[:unit]
            offer.uom = '平方'
            offer.save!
          else
            material = Material.find_by(ply: order.ply, texture: order.texture, color: order.color)
            return '未查到"基础数据——板料"中未找到对应板料，请联系管理员添加！' unless material.present?
            offer = Offer.find_or_create_by(item_id: material.id, item_type: Offer.item_types[:unit],
                                            indent_id: indent.id, order_id: order.id, price: unit.price.to_f)
            # 如果 unit 价格 与标准价格不同，则新建一条 offer 记录
            offer.price = unit.price.to_f
            size = unit.size.split(/[xX*×]/).map(&:to_i)
            if size.present? && size.size == 2
              offer.number = offer.number.to_f + ((unit.number.to_f * size[0] * size[1])/(1000*1000))
            else
              offer.number = offer.number.to_f + unit.number.to_f
            end
            offer.total = offer.price * offer.number
            # mc_ids = [material.ply, material.texture, material.face, material.color]
            # offer.item_name = MaterialCategory.where(id: mc_ids).map(&:name).join("-")
            offer.item_name = [MaterialCategory.find(material.ply).name, MaterialCategory.find(material.texture).name,  MaterialCategory.find(material.color).name].join('-')
            offer.item_type = Offer.item_types[:unit]
            offer.uom = '平方'
            offer.save!
          end
        end
        # 2.2 计算配件报价
        order.parts.each do |part|
          offer = Offer.find_or_create_by(item_id: part.id, item_type: Offer.item_types[:part], indent_id: indent.id, order_id: order.id)
          offer.price = part.price.to_f
          offer.number = offer.number.to_f + part.number.to_f
          offer.total = offer.price * offer.number
          offer.item_name = part.part_category.try(:name)
          offer.item_type = Offer.item_types[:part]
          offer.uom = '个'
          offer.save!
        end
        # 2.3 计算工艺报价
        order.crafts.each do |craft|
          offer = Offer.find_or_create_by(item_id: craft.id, item_type: Offer.item_types[:craft], indent_id: indent.id, order_id: order.id)
          offer.price = craft.price
          offer.number = offer.number.to_f + craft.number.to_f
          offer.total = offer.price * offer.number
          offer.item_name = craft.full_name
          offer.item_type = Offer.item_types[:craft]
          offer.uom = '次'
          offer.save!
        end
        order.offered!
      end
    end
    indent = indent.reload
    # 总订单的状态应该是所有子订单状态改变之后才修改
    #indent.status = Indent.statuses[:offered]
    indent.amount = indent.offers.map{|o| o.order.number * o.total}.sum()
    indent.save!
    return '报价成功！'
  end
end
