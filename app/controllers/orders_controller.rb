class OrdersController < ApplicationController
  include IndentsHelper
  include OrdersHelper
  include OffersHelper
  before_action :set_order, only: [:show, :edit, :update, :destroy, :import, :custom_offer]

  # GET /orders
  # GET /orders.json
  def index
    @unit = Unit.new
    @part = Part.new
    @craft = Craft.new
    @order = Order.new(created_at: Time.now)
    @income = Income.new(username: current_user.name, income_at: Time.now)
    @orders = Order.all.order(created_at: :desc, index: :desc)
    @start_at = params[:start_at].presence || Date.today.beginning_of_month.to_s
    @end_at = params[:end_at].presence || Date.today.end_of_month.to_s

    if current_user.role?('super_admin') || current_user.role?('admin') || current_user.role?('financial')
      @user_id = params[:user_id].presence.to_i
      @orders = @orders.where(handler: @user_id) if @user_id != 0
    elsif current_user.role?('order')
      @user_id = current_user.id
      @orders = @orders.where(handler: @user_id) if current_user.id == @user_id
    else
      @user_id = ''
    end

    @order_category_id = ''
    @order_oftype = ''
    @agents = Agent.all.order(:id)
    @province = Province.find_by_name("湖北省").try(:id)
    @provinces = Province.all.order(:id)
    @city = ""
    @cities = City.where(province_id: @province).order(:id)
    @district = ""
    @districts = District.where(city_id: @city).order(:id)
    # search = ''
    @province = params[:province] unless params[:province].nil?
    @agents = @agents.where(province: @province) unless @province.blank?
    @city = params[:city] unless params[:city].nil?
    # @city 不为空时，才需要过滤
    @agents = @agents.where(city: @city) unless @city.blank?
    @district = params[:district].presence || @district
    # @district 不为空时，才需要过滤
    @agents = @agents.where(district: @district) unless @district.blank?
    @orders = @orders.where(agent_id: @agents) unless @agents.blank?

    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
      @orders = @orders.where("created_at between ? and ?", @start_at, @end_at)
    end

    # 子订单列表搜索条件同时包含 创建时间范围 和 订单号年月 时，搜索结果为空。因此取消此年月查询条件
    search = ''
    #if params[:date].present?
    #  search += "#{params[:date][:year]}%-" if params[:date][:year].present?
    #  search += "#{params[:date][:month]}-" if params[:date][:month].present?
    #end
    search += params[:name] if params[:name].present?
    @orders = @orders.where("name like '%-#{search}'") unless search.blank?

    # 搜索条件 订单类型
    if params[:order_category_id].present?
      @order_category_id = params[:order_category_id]
    end
    @orders = @orders.where(order_category_id: @order_category_id) unless @order_category_id.blank?

    if params[:oftype].present?
      @order_oftype = params[:oftype]
    end
    @orders = @orders.where(oftype: Order.oftypes[@order_oftype]) unless @order_oftype.blank?

    # 搜索条件 代理商ID(@agent_id是返回给view使用)
    if params[:agent_id].present?
      @agent_id = params[:agent_id]
    else
      @agent_id = ''
    end
    @orders = @orders.where("agent_id = ?", @agent_id) unless @agent_id.blank?

    # 查询结果统计信息
    @orders_result = {}
    @orders_result[:total] = @orders.count
    @orders_result[:money] = @orders.pluck(:price).sum
    # 柜体总面积，背板总面积
    @orders_result[:cabinets], @orders_result[:backboard] = 2.times.map{0}
    @orders.each do |order|
      order.units.each do |unit|
        unit_number = 0
        if unit.size.blank?
          unit_number = unit.number
          unit.is_backboard? ? @orders_result[:backboard] += unit_number : @orders_result[:cabinets] += unit_number
        else
          unit_number = unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
          unit.is_backboard? ? @orders_result[:backboard] += unit_number : @orders_result[:cabinets] += unit_number
        end
      end
    end
    # 橱柜
    cupboards = @orders.where(order_category_id: OrderCategory.find_by(name: '橱柜').try(:id))
    @orders_result[:cupboard] = cupboards.count
    @orders_result[:cupboard_cabinets], @orders_result[:cupboard_backboard] = 2.times.map { 0 }
    cupboards.each do |order|
      order.units.each do |unit|
        unit_number = 0
        if unit.size.blank?
          unit_number = unit.number
          unit.is_backboard? ? @orders_result[:cupboard_backboard] += unit_number : @orders_result[:cupboard_cabinets] += unit_number
        else
          unit_number = unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
          unit.is_backboard? ? @orders_result[:cupboard_backboard] += unit_number : @orders_result[:cupboard_cabinets] += unit_number
        end
      end
    end
    # 衣柜
    robes = @orders.where(order_category_id: OrderCategory.find_by(name: '衣柜').try(:id))
    @orders_result[:robe] = robes.count
    @orders_result[:robe_cabinets], @orders_result[:robe_backboard] = 2.times.map { 0 }
    robes.each do |order|
      order.units.each do |unit|
        unit_number = 0
        if unit.size.blank?
          unit_number = unit.number
          unit.is_backboard? ? @orders_result[:robe_backboard] += unit_number : @orders_result[:robe_cabinets] += unit_number
        else
          unit_number = unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
          unit.is_backboard? ? @orders_result[:robe_backboard] += unit_number : @orders_result[:robe_cabinets] += unit_number
        end
      end
    end
    # 门
    doors = @orders.where(order_category_id: OrderCategory.find_by(name: '门').try(:id))
    @orders_result[:door] = doors.count
    @orders_result[:door_count] = 0
    doors.each do |order|
      order.units.each do |unit|
        unit_number = 0
        if unit.size.blank?
          unit_number = unit.number
          @orders_result[:door_count] += unit_number
        else
          unit_number = unit.size.split(/[xX*×]/).map(&:to_i).inject(1){|result, item| result*=item}/(1000*1000).to_f * unit.number
          @orders_result[:door_count] += unit_number
        end
      end
    end
    @orders_result[:part] = @orders.where(order_category_id: OrderCategory.find_by(name: '配件').try(:id)).count
    @orders_result[:other] = @orders.where(order_category_id: OrderCategory.find_by(name: '其他').try(:id)).count
    
    
    # @orders = @orders.sort_by{|o|[o.name.split("-")[0].to_i,o.name.split('-')[1].to_i,o.name.split('-')[2].to_i]}
    respond_to do |format|
      format.html {
        @orders = @orders.page(params[:page])
      }
      format.json {
        @orders = @orders.where("name like '#{params[:term]}%'") if params[:term].present?
        if params[:page]
          per = 6
          size = @orders.offset((params[:page].to_i - 1) * per).size  # 剩下的记录条数
          result = @orders.offset((params[:page].to_i - 1) * per).limit(per)  # 当前显示的所有记录
          # if params[:oftype].present?
          #   result = result.map{|ac| {id: ac.id, text: (ac.full_name)}}  if params[:oftype] == 'full_name'
          #   result = result.map{|ac| {id: ac.id, text: (ac.contacts)}}  if params[:oftype] == 'contacts'
          #   result = result.map{|ac| {id: ac.id, text: (ac.mobile)}}  if params[:oftype] == 'mobile'
          # end
          # result = result << {id: "other", text: '其他收入'} if params[:page].to_i == 1
          result = result.map { |o| {id: o.id, text: o.name}} << {id: '0', text: '其他收入'}
        end
        render json: {:orders => result.reverse, :total => size} 
      }
      format.xls do
        # 分页
        @download = @orders if params[:format] == "xls"
        filename = Time.now.strftime("%Y%m%d%H%M%S%L") + ".xls"
        export_orders(filename, @download, params[:start_at], params[:end_at])
        send_file "#{Rails.root}/public/excels/orders/" + filename, type: 'text/xls; charset=utf-8'
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
    return redirect_to :back, error: '没有权限编辑此订单！' unless current_user.admin? || @order.handler?(current_user)
    return redirect_to :back, error: '请求无效！请检查数据是否有效。' unless params[:order]

    # 删除配件(将标记为删除的配件 _destory 设置为 true)
    order_params_process_parts_attributes = order_params
    if order_params_process_parts_attributes[:parts_attributes]
      order_params_process_parts_attributes[:parts_attributes].each do |k, v|
        order_params_process_parts_attributes[:parts_attributes][k]["_destroy"] = "1" if v[:id] && v[:number].blank?
      end
    end

    # 更新子订单
    Order.transaction do
      # 真实处理者
      really_handler = current_user.admin? ? @order.handler : current_user.id
      indent = @order.indent
      agent = indent.agent
      # 在更新之前保存订单 （原）金额、（原）欠款
      origin_indent_amount = indent.orders.pluck(:price).sum
      origin_indent_arrear = indent.arrear
      origin_order_amount = @order.price
      origin_order_arrear = @order.arrear
      origin_order_income = @order.incomes.pluck(:money).sum
      origin_agent_balance = agent.balance
      # 更新子订单（删除标记为删除的配件）
      @order.update!(order_params_process_parts_attributes)
      # 自定义报价时，查找或创建板料，防止找不到板料
      @order.units.where(is_custom: true).each do |unit|
        m = Material.find_or_create_by(ply: unit.ply, texture: unit.texture, color: unit.color)
        m.full_name = "#{unit.ply_name}-#{unit.texture_name}-#{unit.color_name}" unless m.full_name.present?
        m.buy = 0 unless m.buy.present?
        m.uom = Uom.first.try(:name) if Uom.count > 0
        m.price = unit.price unless m.price.present?
        m.save!
      end

      # 更新子订单金额、代理商余额、收入记录
      sum_units = 0
      # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
      group_units = @order.units.group_by{|u| u.is_custom}
      # 自定义报价中的部件 尺寸 不参与计算
      sum_units += group_units[true].map{|u| u.number * u.price}.sum() if group_units[true]
      # 正常拆单部件 尺寸 参与计算
      sum_units += group_units[false].map{|u| u.size.split(/[xX*×]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum() if group_units[false]
      # 计算 配件 金额
      sum_parts = @order.parts.map{|p| p.number * p.price}.sum()
      # 计算 工艺 金额
      sum_crafts = @order.crafts.map{|c| c.number * c.price}.sum()
      # 新子订单总金额
      new_order_amount = (sum_units + sum_parts + sum_crafts).round
      # 修改订单前后的 金额差 = 原总金额 - 新总金额
      order_remain = origin_order_amount - new_order_amount

      # 金额变小（order_remain > 0)将收入的钱退回到代理商中、金额变大（order_remain <= 0)什么都不处理。同时要求已收金额大于零
      if order_remain > 0 && origin_order_income > 0
        @order.incomes.destroy_all
        income = Income.new(bank_id: Bank.find_by(is_default: 1).id, money: origin_order_income, agent_id: agent.id,
                            username: current_user.username.presence || current_user.email, income_at: Time.now,
                            note: "编辑子订单【#{@order.name}】时，将已收【#{origin_order_income}元】退回【#{agent.full_name}】余额。")
        income.save!
      end
      @order.update!(price: new_order_amount, arrear: new_order_amount, handler: @order.handler.to_i == 0 ? current_user.id : really_handler)
      # 更新总订单金额: 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent.orders.pluck(:price).sum, arrear: indent.orders.pluck(:arrear).sum)
      agent.update!(balance: agent.balance + origin_order_income, arrear: agent.orders.pluck(:arrear).sum,
                    history: agent.orders.pluck(:price).sum)
      # 生成报价单
      create_offer(@order)
      # 修改子订单、总订单的状态
      update_order_status(@order.reload)
    end
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

      order_incomes = order.incomes.pluck(:money).sum
      # 删除子订单前，先将金额退回到代理商余额、修改代理商历史金额
      if agent.balance > 0
        agent.update!(balance: agent.balance + order.price, history: agent.history - order.price)
      else
        agent.update!(arrear: agent.arrear - order.price, history: agent.history - order.price)
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
    # 订单状态小于“已打包” = "packaged" = 3
    # @orders = Order.where("status <= ?", Order.statuses[:packaged])
    # @indents = @orders.group(:indent_id).map(&:indent)
    @indents = Indent.where("status <= ? and status > 1", Indent.statuses[:packaged])
    @indents = @indents.where("agent_id=?", params[:agent_id]) if params[:agent_id].present?
    @indents = @indents.where("name like '%#{params[:indent_name]}%'") if params[:indent_name].present?
    if params[:order_name].present?
      @orders = Order.where("name like '%#{params[:date][:year]}%#{params[:date][:month]}%#{params[:order_name]}'")
      @indents = @indents.where(id: @orders.group(:indent_id).pluck(:indent_id))
    end

    @sent = Sent.new()
  end

  #生产任务
  # GET
  def producing
    @orders = Order.where(status: Order.statuses[:producing])
    search
    @orders = @orders.page(params[:page])
  end

  # 导入文件，或手工输入
  def import
    Order.transaction do
      indent = @order.indent
      agent = indent.agent
      # 在更新之前保存订单 （原）金额、（原）欠款
      origin_indent_amount = indent.orders.pluck(:price).sum
      origin_indent_arrear = indent.arrear
      origin_order_amount = @order.price
      origin_order_arrear = @order.arrear
      origin_agent_balance = agent.balance

      msg = import_order_units(params[:file], @order.name)

      # 更新子订单金额、代理商余额、收入记录  开始
      sum_units = 0
      # 将子订单的所有部件按是否"自定义报价"分组 {true: 自定义报价部件; false: 正常拆单部件}
      group_units = @order.units.group_by{|u| u.is_custom}
      # 自定义报价中的部件 尺寸 不参与计算
      sum_units += group_units[true].map{|u| u.number * u.price}.sum() if group_units[true]
      # 正常拆单部件 尺寸 参与计算
      sum_units += group_units[false].map{|u| u.size.split(/[xX*×]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum() if group_units[false]
      # 计算 配件 金额
      sum_parts = @order.parts.map{|p| p.number * p.price}.sum()
      # 计算 工艺 金额
      sum_crafts = @order.crafts.map{|c| c.number * c.price}.sum()
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
            new_order_remain = new_order_remain - income.money
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
      group_units = @order.units.group_by{|u| u.is_custom}
      # 自定义报价中的部件 尺寸 不参与计算
      sum_units += group_units[true].map{|u| u.number * u.price}.sum() if group_units[true]
      # 正常拆单部件 尺寸 参与计算
      sum_units += group_units[false].map{|u| u.size.split(/[xX*×]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum() if group_units[false]
      # 计算 配件 金额
      sum_parts = @order.parts.map{|p| p.number * p.price}.sum()
      # 计算 工艺 金额
      sum_crafts = @order.crafts.map{|c| c.number * c.price}.sum()
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
      agent.update!(arrear: agent.arrear + indent.amount - origin_indent_amount, history: agent.history + indent.amount - origin_indent_amount)

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
  def custom_offer
    @indent = @order.indent
    @parts = @order.parts
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
    @craft_category = CraftCategory.new
  end

  # GET 打包页面
  # orders/1/package
  # # orders/1/package.pdf
  def package
    # 按照顺序查找： 指定编号、指定ID、第一个（防止打印页面报错）
    if params[:name].present?
      date = params[:date].presence || {year: Date.today.year.to_s, month: Date.today.month.to_s}
      @order =  Order.where("name like '#{date[:year]}%-#{date[:month]}-#{params[:name]}'").first # Order.where("name like '%#{params[:name]}'").first
    elsif params[:id].present?
      @order = Order.find_by_id(params[:id])
    else
      @order = Order.order(created_at: :asc).first
    end
    if @order.present?
      @order_units = @order.units
      @packages = @order.packages
      # 这些值需存在数据库表package中
      # 打印尺寸需存在users表的default_print_size
      if params[:order_unit_ids].present? &&  params[:order_unit_ids] != "{}"
        label_size = params[:order_label_size].to_i if params[:order_label_size]
        logger.debug "自定义日志：" + label_size.to_s
        ids = ActiveSupport::JSON.decode(params[:order_unit_ids])

        # （打印）标签属性设置
        if params[:length].present? && params[:width].present?
          @length = params[:length].to_i
          @width = params[:width].to_i
          current_user.print_size = @length.to_s + '*'+ @width.to_s
          current_user.save! if current_user.changed?
        elsif current_user.print_size
          @length = current_user.print_size.split('*').first.to_i
          @width = current_user.print_size.split('*').last.to_i
        else
          @length = 80
          @width = 60
        end

        ids.each_pair do |key,values|
          # package.print_size =
          unit_ids = values.map  do |v|
            if v =~ /order_unit/
              id = v.gsub(/order_unit_/,'')
              id
            end
          end
          # 保存包装记录
          # package = @order.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','), part_ids: part_ids.compact.join(','))
          package = @order.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','))
          package.label_size = label_size
          package.label_size = 1 if package.label_size == 0
          package.print_size = @length.to_s + "*" + @width.to_s
          package.is_batch = params[:is_batch].to_i if params[:is_batch].present?
          package.save!
          # 更新包装状态（已打印）
          Unit.where(id: unit_ids.compact.uniq).update_all(is_printed: true)
          # 查出已打包（已保存）的部件、配件id，用于界面显示
          packaged_unit_ids = @order.packages.map(&:unit_ids).join(',').split(',').uniq.map(&:to_i)
          unit_ids = @order_units.map(&:id)
          # 订单的所有部件、配件均已打包，修改订单的状态为“已打包”
          if (unit_ids - packaged_unit_ids).empty?
            @order.packaged!
            update_order_status(@order)
          end
        end

        # 返回结果
        respond_to do |format|
          format.html {render :layout => false}
          format.pdf do
            # 打印尺寸毫米（长宽）
            pdf = OrderPdf.new(@length, @width, label_size <= 0 ? 1 : label_size , @order.id)
            send_data pdf.render, filename: "order_#{@order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
          end
        end
      elsif params[:format] == 'pdf'
        redirect_to package_order_path(@order)
      else
        respond_to do |format|
          format.html
        end
      end
    else
      redirect_to unpack_orders_path, warning: '未找到订单！'
    end
  end

  # 已打包
  # GET /orders/packaged
  def packaged
    @orders = Order.where(status: Order.statuses[:packaged])
    search
    @orders = @orders.page(params[:page])
  end

  # 重新打印
  # POST /orders/1/reprint
  def reprint
    @order = Order.find_by_id(params[:id])
    # # 第一次进入 重新打印 页面
    batch_package = @order.packages.where(is_batch: 1).first
    label_size = (params[:label_size].presence || batch_package.label_size).to_i
    batch_package.update(label_size: label_size) if batch_package.present?

    # （打印）标签属性设置
    if params[:length].present? && params[:width].present?
      @length = params[:length].to_i
      @width = params[:width].to_i
      current_user.print_size = @length.to_s + '*'+ @width.to_s
      current_user.save! if current_user.changed?
    elsif current_user.print_size
      @length = current_user.print_size.split('*').first.to_i
      @width = current_user.print_size.split('*').last.to_i
    else
      @length = 80
      @width = 60
    end

    # 返回结果
    respond_to do |format|
      # 请求页面为 html 时，返回到打包页面
      format.html {redirect_to package_order_path(@order)}
      format.pdf do
        # 打印尺寸毫米（长宽）
        pdf = OrderPdf.new(@length, @width, label_size , @order.id)
        send_data pdf.render, type: "application/pdf", disposition: "inline"
      end
    end
  end
  
  # GET 转款
  def change_income
    @order = Order.find_by_id(params[:id]) if params[:id].present?
    if params[:order].present?
      msg = {success: "操作成功！"}
      Order.transaction do
        today = Date.today
        tmp_money = params[:order][:price].to_f
        # 将金额转到指定 子订单
        if params[:order][:id].present?
          target_order = Order.find_by_id(params[:order][:id])
          income = target_order.incomes.new(indent_id: target_order.indent.id, bank_id: Bank.find_by(is_default: 1).id,
                                            income_at: today, username: current_user.name.presence || current_user.email, money: tmp_money,
                                            note: "【#{today}】从子订单【#{@order.name}】手动转入【#{target_order.name}】金额【#{tmp_money}元】")
          income.save!
          @order.incomes.order(created_at: :desc).each do |i|
            break if tmp_money == 0
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
          msg = {notice: "【#{today}】从【#{@order.name}】转出【#{params[:order][:price]}元】到【#{target_order.name}】"}
        else # 将金额转到代理商余额
          agent = @order.agent
          @order.incomes.order(created_at: :desc).each do |i|
            break if tmp_money == 0
            if i.money <= tmp_money
              tmp_money -= i.money
              i.destroy!
            else
              i.update!(money: i.money - tmp_money, note: i.note + ";【#{today}】从【#{@order.name}】转出【#{tmp_money}元】到【#{target_order.name}】")
              tmp_money = 0
            end
          end
          @order.update!(arrear: @order.arrear + params[:order][:price].to_f)
          agent.update!(balance: agent.balance + params[:order][:price].to_f, arrear: agent.orders.pluck(:arrear).sum)
          msg = {notice: "【#{today}】从【#{@order.name}】转出【#{params[:order][:price]}元】代理商【#{agent.full_name}】余额"}
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
  # 根据查询条件查询订单
  def search
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
      @orders = @orders.where("created_at between ? and ?", @start_at, @end_at).order(:id)
    end
    if params[:agent_id].present?
      @agent_id = params[:agent_id]
    else
      @agent_id = ''
    end
    @orders = @orders.where("agent_id = ?", @agent_id) unless @agent_id.blank?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:indent_id, :name, :order_category_id, :ply, :texture, :material_price, :agent_id,
                                  :color, :length, :width, :height, :number, :price, :customer, :delivery_address, :user_id,
                                  :status, :oftype, :note, :deleted, :file, :_destroy, :is_use_order_material, :arrear,
                                  units_attributes: [:id, :full_name, :number, :ply, :texture, :color, :is_custom,
                                                     :length, :width, :size, :uom, :price, :note, :_destroy],
                                  parts_attributes: [:id, :part_category_id, :order_id,
                                                     :name, :buy, :price, :store, :uom, :number, :brand, :note,
                                                     :supply_id, :deleted, :_destroy],
                                  crafts_attributes: [:id, :order_id, :full_name, :uom, :craft_category_id,
                                                      :price, :number, :note, :status, :deleted, :_destroy])
  end
end
