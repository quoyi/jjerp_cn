module OffersHelper
  # 生成指定 indent 的报价单
  def create_offer(order)
    unit_num, unit_money, part_num, part_money, craft_num, craft_money = 6.times.map { 0 }

    # 开启事务，报价单生成要么成功，要么失败。成功时，才删除之前的报价记录。
    ActiveRecord::Base.transaction do
      # order_agent = order.agent
      # agent_origin_history = order_agent.history
      # 1.删除之前的报价单
      # tmp_history = agent_origin_history - order.price
      # order_origin_money = order.price
      # order_origin_arrear = order.arrear
      order.offers.destroy_all
      # 2.进行新报价逻辑
      # 2.1 计算部件报价
      order.units.each do |unit|
        material = Material.find_by(ply: unit.ply, texture: unit.texture, color: unit.color) ||
                   Material.find_by(ply: order.ply, texture: order.texture, color: order.color)
        return '"基础数据 — 板料"中未找到对应板料，请联系管理员添加！' if material.nil?

        # 导入的部件板料存在时，以部件的材质信息为准。否则，以订单的材质信息为准
        offer = Offer.find_or_create_by(item_id: material.id, item_type: Offer.item_types[:unit],
                                        indent_id: order.indent.id, order_id: order.id, price: unit.price.to_f)
        # 如果 unit 价格 与标准价格不同，则新建一条 offer 记录
        offer.price = unit.price.to_f
        # 部件是自定义报价添加时，不需要计算尺寸
        if unit.is_custom
          offer.number = unit.number.to_f # 不需要+ offer.number.to_f
        else # 部件不是自定义报价添加时，需要计算尺寸
          size = unit.size.split(/[xX*×]/).map(&:to_i)
          offer.number = if size.present? && size.size == 2 # 填写尺寸时，按照切割后的数字计算
                           offer.number.to_f + ((unit.number.to_f * size[0] * size[1]) / (1000 * 1000))
                         else # 未填写尺寸时，默认使用 1 / (1000*1000) 计算
                           offer.number.to_f + unit.number.to_f / (1000 * 1000)
                         end
        end
        offer.total = offer.price * offer.number
        unit_money += offer.total
        # mc_ids = [material.ply, material.texture, material.face, material.color]
        # offer.item_name = MaterialCategory.where(id: mc_ids).map(&:name).join("-")
        offer.item_name = [MaterialCategory.find(material.ply).name, MaterialCategory.find(material.texture).name, MaterialCategory.find(material.color).name].join('-')
        offer.item_type = Offer.item_types[:unit]
        offer.uom = unit.uom || '平方'
        offer.note = "#{offer.note}#{unit.note} "
        offer.save!
        unit_num += 1
      end

      # 2.2 计算配件报价
      order.parts.each do |part|
        offer = Offer.find_or_create_by(item_id: part.id, item_type: Offer.item_types[:part], indent_id: order.indent.id, order_id: order.id)
        offer.price = part.price.to_f
        offer.number = offer.number.to_f + part.number.to_f
        offer.total = offer.price * offer.number
        part_money += offer.total
        offer.item_name = part.part_category.try(:name)
        offer.item_type = Offer.item_types[:part]
        offer.uom = part.uom || '个'
        offer.note = "#{offer.note}#{part.note} "
        offer.save!
        part_num += 1
      end

      # 2.3 计算工艺报价
      order.crafts.each do |craft|
        offer = Offer.find_or_create_by(item_id: craft.id, item_type: Offer.item_types[:craft], indent_id: order.indent.id, order_id: order.id)
        offer.price = craft.price
        offer.number = offer.number.to_f + craft.number.to_f
        offer.total = offer.price * offer.number
        craft_money += offer.total
        offer.item_name = craft.full_name
        offer.item_type = Offer.item_types[:craft]
        offer.uom = craft.uom || '次'
        offer.note = "#{offer.note}#{craft.note} "
        offer.save!
        craft_num += 1
      end
      # TODO: 去掉更新逻辑、修改总订单归属后，同时修改代理商金额
      # 修改总订单归属后，同时修改代理商金额
      # 更新报价前的代理商 agent
      # order_agent.update(arrear: order_agent.orders.pluck(:arrear).sum, history: order_agent.orders.pluck(:price).sum)
      # # order_money = unit_money + part_money + craft_money
      # # 更新报价后的代理商 agent
      # indent_agent = order.indent.agent
      # indent_agent.update(arrear: indent_agent.orders.pluck(:arrear).sum, history: indent_agent.orders.pluck(:price).sum)
      # # 更新子订单总金额和欠款
      # order.update(price: order_money, arrear: (order_money - (order_origin_money - order_origin_arrear)).abs,
      #              agent_id: indent_agent.id)
    end
    # order.offering! if unit_num == 0 && part_num == 0 && craft_num == 0
    # indent = indent.reload
    # # 总订单的状态应该是所有子订单状态改变之后才修改
    # #indent.status = Indent.statuses[:offered]
    # indent.amount = indent.offers.map{|o| o.order.number * o.total}.sum()
    # indent.save!
    '报价成功！'
  end
end
