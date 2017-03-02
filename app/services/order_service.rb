class OrderService < BaseService
  # 修改订单
  def self.update_order(handler, order)
    indent = order.indent
    agent = indent.agent
    # 自定义报价时，查找或创建板料，防止找不到板料
    uom = Uom.find_or_create_by(name: '平方')
    order.units.where(is_custom: true).each do |unit|
      m = Material.find_or_create_by(ply: unit.ply, texture: unit.texture, color: unit.color)
      m.full_name ||= "#{unit.ply_name}-#{unit.texture_name}-#{unit.color_name}"
      m.buy = m.buy.to_i
      m.uom = uom
      m.price ||= unit.price
      m.save!
    end
    new_order_amount = calculate_amount(order)
    # 更新订单价格\处理者
    order.update(agent_id: agent.id,
                 price: new_order_amount,
                 arrear: new_order_amount,
                 handler: order.handler.to_i.zero? ? handler.id : order.handler)
    # 更新总订单金额: 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
    indent.update!(amount: indent.orders.pluck(:price).sum,
                   arrear: indent.orders.pluck(:arrear).sum)
    IndentService.sync_status(indent)
    AgentService.sync_status(agent)
    order.incomes.destroy_all
    OfferService.offer(order)
    # 修改子订单、总订单的状态
    sync_status(order)
  end

  # 更新订单配件 (将标记为删除的配件 _destory 设置为 true)
  def self.update_units_parts_crafts(order, order_params)
    order_params[:parts_attributes].each do |k, v|
      order_params[:parts_attributes][k]['_destroy'] = '1' if v[:id] && v[:number].blank?
    end
    order.update(order_params)
  end

  # 列出报价单
  def self.offer(order_id)
    order = Order.find(order_id)
    order.offers
  end

  # 修改子订单、总订单状态
  def self.sync_status(order)
    indent = order.indent
    offers = order.reload.offers
    status = Order.statuses[order.status]
    order.offered! if status.zero? && !offers.empty?
    order.offering! if status == 1 && offers.empty?
    # 所有子订单中，最小状态值作为总订单的状态
    min_status = indent.orders.map { |o| Order.statuses[o.status] }.min
    max_status = indent.orders.map { |o| Order.statuses[o.status] }.max
    indent.update!(status: min_status, max_status: max_status)
  end

  private_class_method
  # 计算订单金额
  def self.calculate_amount(order)
    # 更新子订单金额、代理商余额、收入记录
    sum_units = 0
    # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
    group_units = order.units.group_by(&:is_custom)
    # 自定义报价中的部件 尺寸 不参与计算
    sum_units += group_units[true].map { |u| u.number * u.price }.sum if group_units[true]
    # 正常拆单部件 尺寸 参与计算
    if group_units[false]
      sum_units += group_units[false].map { |u| u.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result *= item } / (1000 * 1000).to_f * u.number * u.price }.sum
    end
    # 计算 配件 金额
    sum_parts = order.parts.map { |p| p.number * p.price }.sum
    # 计算 工艺 金额
    sum_crafts = order.crafts.map { |c| c.number * c.price }.sum
    # 子订单总金额 = 部件价格 + 配件价格 + 工艺价格
    (sum_units + sum_parts + sum_crafts).round(2)
  end
end
