class OrdersController < ApplicationController
  include IndentsHelper
  include OrdersHelper
  include OffersHelper
  before_action :set_order, only: %i[show edit update destroy import custom_offer reprint]

  # GET /orders
  # GET /orders.json
  def index
    # 页面初始化参数
    params[:start_at] ||= Date.today.beginning_of_month
    params[:end_at] ||= Date.today.end_of_month
    params[:province] = Province.find_by_name('湖北省').try(:id) if params[:province].blank?
    @order = Order.new(created_at: Time.now)
    # @income = Income.new(username: current_user.name, income_at: Time.now)
    # View 使用的省市县集合数据
    @provinces = Province.all.order(:id)
    @cities = City.where(province_id: params[:province]).order(:id)
    @districts = District.where(city_id: params[:city]).order(:id)
    # 查询条件hash，优化“一次查询”
    order_condition = {}
    if current_user.role?('super_admin') || current_user.role?('admin') || current_user.role?('financial')
      order_condition[:handler] = params[:user_id] if params[:user_id].to_i != 0
    elsif current_user.id == params[:user_id].to_i
      order_condition[:handler] = params[:user_id]
    end
    # 搜索条件 订单类型
    order_condition[:order_category_id] = params[:order_category_id] if params[:order_category_id].present?
    # 搜索指定订单类型
    order_condition[:oftype] = Order.oftypes[params[:oftype]] if params[:oftype].present?
    # 搜索指定代理商订单 或 模糊查询省市县所有代理商
    if params[:agent_id].present?
      order_condition[:agent_id] = params[:agent_id]
    else
      agent_condition = {}
      agent_condition[:province] = params[:province]
      agent_condition[:city] = params[:city] if params[:city].present?
      agent_condition[:district] = params[:district] if params[:district].present?
      @agents = Agent.where(agent_condition)
      order_condition[:agent_id] = @agents.any? ? @agents.pluck(:id) : 0
    end
    @orders = Order.where(order_condition)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @orders = @orders.where('created_at BETWEEN ? AND ?',
                              params[:start_at].to_datetime.beginning_of_day,
                              params[:end_at].to_datetime.end_of_day)
    end
    # 订单号模糊查询：子订单列表搜索条件同时包含 创建时间范围 和 订单号年月 时，搜索结果为空。因此取消此年月查询条件
    @orders = @orders.where("name like '%-#{params[:name]}'") if params[:name].present?
    @orders = @orders.order(created_at: :desc, name: :desc)

    # 查询结果统计信息
    @orders_result = {}
    @orders_result[:total] = @orders.count
    @orders_result[:money] = @orders.pluck(:price).sum
    # 柜体总面积，背板总面积
    @orders_result[:cabinets], @orders_result[:backboard] = Array.new(2) { 0 }
    @orders.each do |order|
      order.units.each do |unit|
        unit_number = if unit.size.blank?
                        unit.number
                      else
                        unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * unit.number
                      end
        unit.backboard? ? @orders_result[:backboard] += unit_number : @orders_result[:cabinets] += unit_number
      end
    end
    # 橱柜
    cupboards = @orders.where(order_category_id: OrderCategory.find_by(name: '橱柜').try(:id))
    @orders_result[:cupboard] = cupboards.count
    @orders_result[:cupboard_cabinets], @orders_result[:cupboard_backboard] = Array.new(2) { 0 }
    cupboards.each do |order|
      order.units.each do |unit|
        unit_number = if unit.size.blank?
                        unit.number
                      else
                        unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * unit.number
                      end
        unit.backboard? ? @orders_result[:cupboard_backboard] += unit_number : @orders_result[:cupboard_cabinets] += unit_number
      end
    end
    # 衣柜
    robes = @orders.where(order_category_id: OrderCategory.find_by(name: '衣柜').try(:id))
    @orders_result[:robe] = robes.count
    @orders_result[:robe_cabinets], @orders_result[:robe_backboard] = Array.new(2) { 0 }
    robes.each do |order|
      order.units.each do |unit|
        unit_number = if unit.size.blank?
                        unit.number
                      else
                        unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * unit.number
                      end
        unit.backboard? ? @orders_result[:robe_backboard] += unit_number : @orders_result[:robe_cabinets] += unit_number
      end
    end
    # 门
    doors = @orders.where(order_category_id: OrderCategory.find_by(name: '门').try(:id))
    @orders_result[:door] = doors.count
    @orders_result[:door_count] = 0
    doors.each do |order|
      order.units.each do |unit|
        unit_number = if unit.size.blank?
                        unit.number
                      else
                        unit.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * unit.number
                      end
        @orders_result[:door_count] += unit_number
      end
    end
    @orders_result[:part] = @orders.where(order_category_id: OrderCategory.find_by(name: '配件').try(:id)).count
    @orders_result[:other] = @orders.where(order_category_id: OrderCategory.find_by(name: '其他').try(:id)).count

    respond_to do |format|
      format.html do
        @orders = @orders.includes(:packages, indent: [:agent]).page(params[:page])
      end
      format.json do
        @orders = @orders.where("name like '#{params[:term]}%'") if params[:term].present?
        if params[:page]
          per = 6
          size = @orders.offset((params[:page].to_i - 1) * per).size # 剩下的记录条数
          result = @orders.offset((params[:page].to_i - 1) * per).limit(per) # 当前显示的所有记录
          result = result.map { |o| { id: o.id, text: o.name } } << { id: '0', text: '其他收入' }
        end
        render json: { orders: result.reverse, total: size }
      end
      format.xls do
        # 分页
        @download = @orders if params[:format] == 'xls'
        filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}.xls"
        export_orders(filename, @download, params[:start_at], params[:end_at])
        send_file Rails.root.join("public/excels/orders/#{filename}"), type: 'text/xls; charset=utf-8'
      end
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
    @craft = Craft.new
    # 这里可能需要修改, 应查找unit_category并获取ID值，再查找对应的material；而不是写固定值“1”
    @units = Unit.where(order_id: @order.id)
    @parts = Part.where(order_id: @order.id)
    @crafts = Craft.where(order_id: @order.id)
    @indent = @order.indent
    @agent = @indent.agent
    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  # 查找 指定 name(订单号) 的子订单
  # GET /orders/find.json
  def find
    @order = Order.where("name like '#{params[:year]}%-#{params[:month]}-#{params[:name]}'").first if params[:year].present? && params[:month].present? && params[:name].present?
    if @order.present?
      agent = @order.agent
      data = { agent_id: agent.try(:id), agent_name: agent.try(:full_name), agent_balance: agent.try(:balance), order_id: @order.try(:id),
               order_customer: @order.indent.try(:customer), order_price: @order.try(:price), order_arrear: @order.try(:arrear) }
    else
      data = {}
    end
    respond_to do |format|
      format.json { render json: data }
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to :back, success: '子订单创建成功！'
    else
      redirect_to :back, error: '子订单创建失败！'
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    # 检查权限
    return redirect_to :back, error: '没有权限编辑此订单！' if !current_user.admin? && @order.handler != 0 && @order.handler != current_user.id
    return redirect_to :back, error: '请求无效！请检查数据是否有效。' unless params[:order]

    # 仅仅只是修改订单状态时
    if order_params[:status].present? && order_params[:status] != @order.status
      case order_params[:status]
      when 'producing'
        @order.update(status: order_params[:status], produced_at: Time.now)
      when 'packaged'
        @order.update(status: order_params[:status], packaged_at: Time.now)
      when 'sent'
        @order.update(status: order_params[:status], sent_at: Time.now)
      when 'over'
        @order.update(status: order_params[:status], sent_at: Time.now)
      else
        @order.update(status: order_params[:status])
      end
      return redirect_to :back, notice: '订单状态已修改.'
    end

    OrderService.update_units_parts_crafts(@order, order_params) if order_params[:parts_attributes]
    OrderService.update_order(current_user, @order)
    # 子订单列表页面更新后，应该返回到列表页面
    redirect_to :back, notice: '子订单编辑成功！'
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    Order.transaction do
      indent = @order.indent
      agent = indent.agent
      order = @order
      @order.incomes.destroy_all
      @order.destroy!
      # 更新总订单金额、欠款
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent.orders.pluck(:price).sum, arrear: indent.orders.pluck(:arrear).sum)
      # 删除子订单前，先将金额退回到代理商余额、修改代理商历史金额
      if agent.balance.positive?
        agent.update!(balance: agent.balance + order.price, history: agent.history - order.price)
      else
        agent.update!(history: agent.history - order.price)
      end

      # 生成报价单
      create_offer(order)
      # 修改子订单、总订单的状态
      update_order_status(order)
    end
    redirect_to orders_url, notice: '子订单已删除。'
  end

  # 未发货
  def not_sent
    @sent = Sent.new
    @indents = Indent.where('max_status >= ? AND status != ?',
                            Indent.statuses[:packaged],
                            Indent.statuses[:sending]).order(created_at: :desc)
    if params[:order_name].present?
      @indents = @indents.joins('LEFT JOIN orders ON orders.indent_id = indents.id')
                         .uniq
                         .where('orders.name like ?',
                                "%#{params[:date][:year]}%#{params[:date][:month]}%#{params[:order_name]}%")
    end
    @indents = @indents.where(agent_id: params[:agent_id]) if params[:agent_id].present?
    @indents = @indents.where("name like '%#{params[:indent_name]}%'") if params[:indent_name].present?
    @indents = @indents.includes(:agent, :sent, orders: %i[packages order_category sent]).page(params[:page])
  end

  # 生产任务
  # GET
  def producing
    condition = {
      status: Order.statuses[:producing]
    }
    condition[:agent_id] = params[:agent_id] if params[:agent_id].present?
    @orders = Order.where(condition)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @orders = @orders.where('created_at BETWEEN ? AND ?',
                              params[:start_at].to_datetime.beginning_of_day,
                              params[:end_at].to_datetime.end_of_day)
    end
    @orders = @orders.page(params[:page])
  end

  # 导入文件，或手工输入
  def import
    Order.transaction do
      indent = @order.indent
      agent = indent.agent
      # 在更新之前保存订单 （原）金额、（原）欠款
      origin_indent_amount = indent.orders.pluck(:price).sum
      # origin_indent_arrear = indent.arrear
      origin_order_amount = @order.price
      # origin_order_arrear = @order.arrear
      origin_agent_balance = agent.balance

      # msg = import_order_units(params[:file], @order.name)
      import_order_units(params[:file], @order.name)

      # 更新子订单金额、代理商余额、收入记录  开始
      sum_units = 0
      # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
      group_units = @order.units.group_by(&:is_custom)
      # 自定义报价中的部件 尺寸 不参与计算
      sum_units += group_units[true].map { |u| u.number * u.price }.sum if group_units[true]
      # 正常拆单部件 尺寸 参与计算
      sum_units += group_units[false].map { |u| u.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * u.number * u.price }.sum if group_units[false]
      # 计算 配件 金额
      sum_parts = @order.parts.map { |p| p.number * p.price }.sum
      # 计算 工艺 金额
      sum_crafts = @order.crafts.map { |c| c.number * c.price }.sum
      # 新子订单总金额
      new_order_amount = (sum_units + sum_parts + sum_crafts).round
      # 子订单金额 = 子订单部件合计 + 子订单配件合计 + 子订单工艺费合计
      @order.update!(price: new_order_amount)
      # 原金额 >= 新金额 时，金额差 返回到 代理商余额，更新总订单的金额、欠款
      # 原金额 < 新金额  时，从代理商余额中扣除 金额差： 余额 > 金额差，更新总订单金额、欠款； 余额 < 金额差，更新子订单欠款，代理商余额为0

      # 金额差 = 原总金额 - 新总金额
      order_remain = origin_order_amount - new_order_amount
      # 子订单： 原金额 大于 现金额
      if order_remain >= 0
        # 返回金额差到代理商余额中
        agent.update!(balance: origin_agent_balance + order_remain)
        new_order_remain = order_remain
        @order.incomes.each do |income|
          # 收入记录的金额 <= 金额差： 删掉收入记录、继续找下一个收入
          if income.money <= new_order_remain
            new_order_remain -= income.money
            income.destroy!
          else
            # 收入记录的金额 > 金额差： 更新收入记录、收入备注
            income.update!(money: income.money - new_order_remain,
                           note: income.note + ";#{@order.name}的金额差#{new_order_remain}")
          end
        end
      else
        # 从代理商余额中扣款；不足的作为订单欠款
        new_agent_balance = origin_agent_balance - order_remain.abs
        if new_agent_balance >= 0
          agent.update!(balance: new_agent_balance)
          income = Income.new(indent_id: indent.id, order_id: @order.id, money: order_remain.abs,
                              bank_id: Bank.find_by(is_default: 1).id, username: current_user.name,
                              income_at: Time.now, note: "代理商余额扣除编辑#{@order.name}前后的金额差")
          income.save!
        else
          agent.update!(balance: 0)
          # 添加扣款记录
          income = Income.new(indent_id: indent.id, order_id: @order.id, money: new_agent_balance.abs,
                              bank_id: Bank.find_by(is_default: 1).id, username: current_user.name,
                              income_at: Time.now, note: "代理商余额扣除编辑#{@order.name}前后的金额差")
          income.save!
          # 代理商余额不足扣除的作为订单欠款
          order.update!(arrear: new_agent_balance.abs)
        end
      end
      # 更新子订单金额、代理商余额、收入记录  结束

      # 更新子订单金额
      sum_units = 0
      # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
      group_units = @order.units.group_by(&:is_custom)
      # 自定义报价中的部件 尺寸 不参与计算
      sum_units += group_units[true].map { |u| u.number * u.price }.sum if group_units[true]
      # 正常拆单部件 尺寸 参与计算
      sum_units += group_units[false].map { |u| u.size.split(/[xX*×]/).map(&:to_i).inject(1) { |result, item| result * item } / (1000 * 1000).to_f * u.number * u.price }.sum if group_units[false]
      # 计算 配件 金额
      sum_parts = @order.parts.map { |p| p.number * p.price }.sum
      # 计算 工艺 金额
      sum_crafts = @order.crafts.map { |c| c.number * c.price }.sum
      # 子订单金额 = 子订单部件合计 + 子订单配件合计 + 子订单工艺费合计
      @order.update!(price: (sum_units + sum_parts + sum_crafts).round)

      # 更新总订单金额
      indent = @order.indent
      # 总订单 -- 所有子订单金额合计
      indent_amount = indent.orders.pluck(:price).sum
      # 总订单 -- 所有收入金额合计
      indent_income = indent.incomes.pluck(:money).sum
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent_amount, arrear: indent_amount - indent_income)

      # 更新代理商 历史欠款合计、历史订单合计
      agent = indent.agent
      agent.update!(history: agent.history + indent.amount - origin_indent_amount)

      # 生成报价单
      create_offer(@order)
      # 修改子订单、总订单的状态
      update_order_status(@order.reload)
    end
    redirect_to :back, notice: msg
  end

  # 未打包
  # GET /orders/unpack
  def unpack
    # @orders = Order.where(status: Order.statuses[:producing])
    # @orders.each do |order|
    #   # 子订单状态为 未打包，且部件数量为0
    #   if order.status == "producing" && order.units.size == 0
    #     order.packaged!
    #     order.update_attributes(package_num: 0) # 打包数为0
    #     update_order_status(order)
    #   end
    # end
    # @orders = @orders.reload#.where(status: Order.statuses[:producing])
    # @orders = @orders.page(params[:page])
  end

  # 自定义报价
  # GET /orders/:order_id/custom_offer
  def custom_offer
    @indent = @order.indent
    @parts = @order.parts
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
    @craft_category = CraftCategory.new
  end

  # 打包页面
  # Post orders/package
  def package
    # TODO: 打印预览页面刷新时,显示错误
    # 按照顺序查找： 指定编号、指定ID、第一个（防止打印页面报错）
    orders = Order.where(status: Order.statuses[:producing]..Order.statuses[:sending])
    if params[:name].present?
      date = params[:date].presence || { year: Date.today.year.to_s, month: Date.today.month.to_s }
      @order = orders.where("name like '#{date[:year]}%-#{date[:month]}-#{params[:name]}'").first
    elsif params[:id].present?
      @order = orders.find(params[:id])
    end
    if @order.present?
      # 给前端使用
      @order_units = @order.units
      @packages = @order.packages
      # 打印尺寸需存在users表的default_print_size
      label_size = params[:order_label_size].to_i.positive? ? params[:order_label_size].to_i : 1
      # （打印）标签属性设置
      @length = (params[:length].presence || 80).to_i
      @width = (params[:width].presence || 60).to_i
      if @order.order_category.name == '配件' # @order.packages.destroy_all
        package = Package.find_or_create_by(order_id: @order.id)
        package.part_ids = @order.parts.pluck(:id).join(',')
        package.label_size = label_size
        package.print_size = "#{@length}*#{@width}"
        package.is_batch = params[:is_batch].to_i if params[:is_batch].present?
        package.save!
        @order.parts.update_all(is_printed: true)
        @order.update(status: 'packaged', packaged_at: Time.now)
        IndentService.sync_status(@order.indent)
      elsif params[:order_unit_ids].present? && params[:order_unit_ids] != '{}'
        # 这些值需存在数据库表package中
        logger.debug "自定义日志：#{label_size}"
        ids = ActiveSupport::JSON.decode(params[:order_unit_ids])

        ids.each_value do |value|
          unit_ids = value.map  do |v|
            if v =~ /order_unit/
              id = v.gsub(/order_unit_/, '')
              id
            end
          end
          # 保存包装记录
          package = Package.find_or_create_by(order_id: @order.id)
          package.unit_ids = unit_ids.compact.join(',')
          package.label_size = label_size
          package.print_size = "#{@length}*#{@width}"
          package.is_batch = params[:is_batch].to_i if params[:is_batch].present?
          package.save!
          # 更新包装状态（已打印）
          Unit.where(id: unit_ids.compact.uniq).update_all(is_printed: true)
          # 查出已打包（已保存）的部件、配件id，用于界面显示
          packaged_unit_ids = @order.packages.map(&:unit_ids).join(',').split(',').uniq.map(&:to_i)
          unit_ids = @order_units.map(&:id)
          # 订单的所有部件、配件均已打包，修改订单的状态为“已打包”
          if (unit_ids - packaged_unit_ids).empty?
            @order.update(status: 'packaged', packaged_at: Time.now)
            IndentService.sync_status(@order.indent)
          end
        end
      end

      # 返回结果
      respond_to do |format|
        format.html
        format.pdf do
          # 打印尺寸毫米（长宽）
          pdf = OrderPdf.new(@length, @width, label_size, @order)
          send_data pdf.render, filename: "order_#{@order.id}.pdf",
                                type: 'application/pdf',
                                disposition: 'inline'
        end
      end
    else
      redirect_to unpack_orders_path, warning: '订单未报价或不存在！'
    end
  end

  # 打包
  # Post orders/:order_id/pack
  def pack
    # length = (params[:length].presence || 80).to_i
    # width = (params[:width].presence || 60).to_i
    # 批量打印

    # 单包打印
  end

  # 已打包
  # GET /orders/packaged
  def packaged
    condition = {
      status: Order.statuses[:packaged]
    }
    condition[:agent_id] = params[:agent_id] if params[:agent_id].present?
    @orders = Order.where(condition)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @orders = @orders.where('created_at BETWEEN ? AND ?',
                              params[:start_at].to_datetime.beginning_of_day,
                              params[:end_at].to_datetime.end_of_day)
    end
    @orders = @orders.page(params[:page])
  end

  # 重新打印
  # POST /orders/1/reprint
  def reprint
    packages = @order.packages
    label_size = params[:label_size].to_i
    length = (params[:length].presence || 80).to_i
    width = (params[:width].presence || 60).to_i
    if label_size.positive? && packages.present?
      packages.destroy_all
      @order.packages.create(unit_ids: @order.units.pluck(:id).join(','),
                             part_ids: @order.parts.pluck(:id).join(','),
                             label_size: label_size,
                             print_size: "#{length}*#{width}",
                             is_batch: true)
    end
    respond_to do |format|
      # 请求页面为 html 时，返回到打包页面
      format.html { redirect_to package_orders_path(id: @order) }
      format.pdf do
        if label_size.zero?
          redirect_to package_orders_path(id: @order)
        else
          # 打印尺寸毫米（长宽）
          pdf = OrderPdf.new(length, width, label_size, @order)
          send_data pdf.render, type: 'application/pdf', disposition: 'inline'
        end
      end
    end
  end

  # GET 转款
  def change_income
    @order = Order.find_by_id(params[:id]) if params[:id].present?
    if params[:order].present?
      msg = { success: '操作成功！' }
      Order.transaction do
        today = Date.today
        tmp_money = params[:order][:price].to_f
        # 将金额转到指定 子订单
        if params[:order][:id].present?
          target_order = Order.find_by_id(params[:order][:id])
          target_order.incomes.create(indent_id: target_order.indent.id,
                                      income_at: today,
                                      username: current_user.name.presence || current_user.email,
                                      money: tmp_money,
                                      note: "【#{today}】从子订单【#{@order.name}】手动转入【#{target_order.name}】金额【#{tmp_money}元】")
          @order.incomes.order(created_at: :desc).each do |i|
            break if tmp_money.zero?

            if i.money <= tmp_money
              tmp_money -= i.money
              i.destroy!
            else
              i.update!(money: i.money - tmp_money, note: i.note + ";【#{today}】从【#{@order.name}】转出【#{tmp_money}元】到【#{target_order.name}】")
              tmp_money = 0
            end
          end
          target_order.update!(arrear: target_order.arrear - params[:order][:price].to_f)
          @order.update!(arrear: @order.arrear + params[:order][:price].to_f)
          msg = { notice: "【#{today}】从【#{@order.name}】转出【#{params[:order][:price]}元】到【#{target_order.name}】" }
        else # 将金额转到代理商余额
          agent = @order.agent
          @order.incomes.order(created_at: :desc).each do |i|
            break if tmp_money.zero?

            if i.money <= tmp_money
              tmp_money -= i.money
              i.destroy!
            else
              i.update!(money: i.money - tmp_money, note: i.note + ";【#{today}】从【#{@order.name}】转出【#{tmp_money}元】到【#{target_order.name}】")
              tmp_money = 0
            end
          end
          @order.update!(arrear: @order.arrear + params[:order][:price].to_f)
          agent.update!(balance: agent.balance + params[:order][:price].to_f)
          msg = { notice: "【#{today}】从【#{@order.name}】转出【#{params[:order][:price]}元】代理商【#{agent.full_name}】余额" }
        end
        # 重新计算总订单欠款
        indent = @order.indent
        indent.update!(arrear: indent.orders.pluck(:arrear).sum)
      end
      redirect_to orders_path, msg
    else
      render layout: false
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:indent_id, :name, :order_category_id, :ply, :texture, :material_price, :agent_id,
                                  :color, :length, :width, :height, :number, :price, :customer, :delivery_address, :user_id,
                                  :status, :oftype, :note, :deleted, :file, :_destroy, :is_use_order_material, :arrear,
                                  units_attributes: %i[id full_name number ply texture color is_custom
                                                       length width size uom price note _destroy],
                                  parts_attributes: %i[id part_category_id order_id
                                                       name buy price store uom number brand note
                                                       supply_id deleted _destroy],
                                  crafts_attributes: %i[id order_id full_name uom craft_category_id
                                                        price number note status deleted _destroy])
  end
end
