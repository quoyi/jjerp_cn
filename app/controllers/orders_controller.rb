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
    @start_at = Date.today.beginning_of_month.to_s
    @end_at = Date.today.end_of_month.to_s
    @role = (params[:role] || '').to_i
    # if @role == Role.find_by(name: ['超级管理员', '管理员']).try(:id)
    if @role == Role.find_by(name: '下单员').try(:id)
      @orders = @orders.where(handler: current_user.id) if current_user.roles.pluck(:id).include?(@role)
    # else
    end
    
    @order_category_id = ''
    @agents = Agent.all.order(:id)
    @province = Province.find_by_name("湖北省").try(:id)
    @provinces = Province.all.order(:id)
    @city = City.find_by_name("武汉市").try(:id)
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
    @orders = @orders.where(agent_id: @agents)

    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
    end
    @orders = @orders.where("created_at between ? and ?", @start_at, @end_at)
    # 搜索条件 订单类型
    if params[:order_category_id].present?
      @order_category_id = params[:order_category_id]
    end
    @orders = @orders.where(order_category_id: @order_category_id) unless @order_category_id.blank?
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
    @orders_result[:cupboard] = @orders.where(order_category_id: OrderCategory.find_by(name: '橱柜').try(:id)).count
    @orders_result[:robe] = @orders.where(order_category_id: OrderCategory.find_by(name: '衣柜').try(:id)).count
    @orders_result[:door] = @orders.where(order_category_id: OrderCategory.find_by(name: '门').try(:id)).count
    @orders_result[:part] = @orders.where(order_category_id: OrderCategory.find_by(name: '配件').try(:id)).count
    @orders_result[:other] = @orders.where(order_category_id: OrderCategory.find_by(name: '其他').try(:id)).count
    # 分页
    @download = @orders if params[:format] == "xls"
    @orders = @orders.page(params[:page])
    # @orders = @orders.sort_by{|o|[o.name.split("-")[0].to_i,o.name.split('-')[1].to_i,o.name.split('-')[2].to_i]}
    respond_to do |format|
      format.html 
      format.xls do
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
    handler = @order.handler.to_i
    return redirect_to :back, error: '没有权限编辑此订单！' if handler != 0 && handler != current_user.id
    return redirect_to @order, error: '请求无效！请检查数据是否有效。' unless params[:order]
    Order.transaction do
      indent = @order.indent
      agent = indent.agent
      # 在更新之前保存订单 （原）金额、（原）欠款
      origin_indent_amount = indent.orders.pluck(:price).sum
      origin_indent_arrear = indent.arrear
      origin_order_amount = @order.price
      origin_order_arrear = @order.arrear
      origin_agent_balance = agent.balance

      @order.update!(order_params)
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
      # 原金额 >= 新金额 时，金额差 返回到 代理商余额，更新总订单的金额、欠款
      # 原金额 < 新金额  时，从代理商余额中扣除 金额差： 余额 > 金额差，更新总订单金额、欠款； 余额 < 金额差，更新子订单欠款，代理商余额为0

      # 金额差 = 原总金额 - 新总金额
      order_remain = origin_order_amount - new_order_amount
      # 子订单： (原)金额 大于 (现)金额（总金额减少，删除部件、配件、工艺操作）
      if order_remain >= 0
        income_and_balance = @order.incomes.pluck(:money).sum + agent.balance
        income_remain = income_and_balance - new_order_amount
        # 已收总金额 > 修改后的总金额，需要将多余的钱退回代理商余额
        if income_remain >= 0
          tmp_agent_balance = agent.balance
          tmp_agent_arrear = agent.arrear
          # 订单还有欠款时(修改前，收入不足)
          if @order.arrear > 0
            tmp_order_remain = @order.incomes.pluck(:money).sum - new_order_amount
          else
            tmp_order_remain = order_remain
          end
          # 删除扣款记录
          @order.incomes.order(created_at: :desc).each do |income|
            break if tmp_order_remain == 0
            # 单条收入记录的金额 <= 修改前后的金额差
            if income.money <= tmp_order_remain
              tmp_order_remain -= income.money
              # 先将收入记录的金额返回到代理商余额中
              tmp_agent_balance += income.money
              income.destroy!
            else
              # 更新收入记录中的金额
              income.update!(money: income.money - tmp_order_remain, note: income.note + ";编辑子订单时，返回#{tmp_order_remain}到代理商余额")
              # 将收入记录的金额返回到代理商余额中
              tmp_agent_balance += tmp_order_remain
              tmp_order_remain = 0
            end
          end
          new_order_arrear = new_order_amount - @order.incomes.pluck(:money).sum
          tmp_agent_arrear -= (origin_order_arrear - new_order_arrear)
          agent.update!(balance: tmp_agent_balance, arrear: tmp_agent_arrear, history: agent.history - order_remain)
          @order.update!(price: new_order_amount, arrear: 0, handler: current_user.id)
        else # 收入金额不够时(因为不能同时存在余额和欠款，而且已收金额小于订单总金额)
          @order.update!(price: new_order_amount, arrear: new_order_amount - @order.incomes.pluck(:money).sum, handler: current_user.id)
          agent.update!(arrear: agent.arrear - order_remain, history: agent.history - order_remain)
        end
      else # 添加部件、配件、工艺操作
        # 代理商余额之和大于0时，才扣除金额、添加到款记录
        if agent.balance > 0
          income_and_balance = @order.incomes.pluck(:money).sum + agent.balance
          income_remain = income_and_balance - new_order_amount
          # 已收总金额 > 修改后的总金额，从代理商余额扣除不足金额
          if income_remain >= 0
            # 新建一条收入记录，记载从代理商余额中扣除款项
            income = @order.incomes.new(indent_id: indent.id, bank_id: Bank.find_by(is_default: 1).id, money: order_remain.abs,
                                        username: current_user.name, income_at: Time.now, note: "从代理商余额中扣款#{order_remain.abs}")
            income.save!
            agent.update!(balance: agent.balance - order_remain.abs, history: agent.history + order_remain.abs)
          else # 收入金额不够时(因为不能同时存在余额和欠款，而且已收金额小于订单总金额)
            @order.update(price: new_order_amount, arrear: income_remain.abs, handler: current_user.id)
            income = @order.incomes.new(indent_id: indent.id, bank_id: Bank.find_by(is_default: 1).id, money: agent.balance,
                                        username: current_user.name, income_at: Time.now, note: "从代理商余额中扣款#{agent.balance}")
            income.save!
            agent.update!(balance: 0, arrear: agent.arrear + income_remain.abs,
                          history: agent.history + order_remain.abs)
          end
        else
          @order.update!(price: new_order_amount, arrear: @order.arrear +  order_remain.abs, handler: current_user.id)
          agent.update!(arrear: agent.arrear + order_remain.abs, history: agent.history + order_remain.abs)
        end
      end

      # 更新后代理商有余额时，查找子订单之后的所有子订单，重新扣除金额
      # 更新总订单金额
      # 总订单 -- 所有子订单 （新）金额合计
      indent_amount = indent.orders.pluck(:price).sum
      # 总订单 -- 所有收入 （新）金额合计
      indent_arrear = indent.orders.pluck(:arrear).sum
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent_amount, arrear: indent_arrear)
      
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
    # binding.pry
    @orders = Order.where(status: Order.statuses[:packaged])
    @indents = @orders.group(:indent_id).map(&:indent)
    @sent = Sent.new()
  end

  #生产任务
  def producing
    @orders = Order.where(status: Order.statuses[:producing])
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

  # 自定义报价
  def custom_offer
    @indent = @order.indent
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
    @craft_category = CraftCategory.new
  end

  # 未打包
  # GET /orders/unpack
  def unpack
    @orders = Order.where(status: Order.statuses[:producing])
    @orders.each do |order|
      # 子订单状态为 未打包，且部件数量为0
      if order.status == "producing" && order.units.size == 0
        order.packaged!
        order.update_attributes(package_num: 0) # 打包数为0
        update_order_status(order)
      end
    end
    @orders = @orders.reload#.where(status: Order.statuses[:producing])
    # @orders = @orders.page(params[:page])
  end

  # 已打包
  # GET /orders/packaged
  def packaged
    @orders = Order.where(status: Order.statuses[:packaged])
    @orders = @orders.page(params[:page])
  end

  # GET 打包页面
  # orders/1/package
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

  # 重新打印
  # POST /orders/1/reprint
  def reprint
    @order = Order.find_by_id(params[:id])
    label_size = params[:label_size].to_i
    batch_package = @order.packages.where(is_batch: 1).first
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
        send_data pdf.render, filename: "order_#{@order.id}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
    end
  end

  # GET 转款
  def change_income
    @order = Order.find_by_id(params[:id]) if params[:id].present?
    if params[:order].present?
      target_order = Order.find_by_id(params[:order][:id])
      msg = "操作成功！"
      Order.transaction do
        now = Time.now
        tmp_money = params[:order][:price].to_f
        if params[:order][:id].present?
          income = target_order.incomes.new(indent_id: target_order.indent.id, bank_id: Bank.find_by(is_default: 1).id,
                                            income_at: now, username: current_user.name, money: tmp_money,
                                            note: "从订单#{@order.name}手动转款#{tmp_money}")
          income.save!
          @order.incomes.order(created_at: :desc).each do |i|
            break if tmp_money == 0
            if i.money <= tmp_money
              tmp_money -= i.money
              i.destroy!
            else
              i.update!(money: i.money - tmp_money, note: i.note + ";#{current_user.name}于#{now}从此订单转出#{tmp_money}到#{target_order.name}")
              tmp_money = 0
            end
          end
          @order.update!(arrear: @order.arrear + params[:order][:price].to_f)
          msg = "成功将#{@order.name}的#{params[:order][:price]}转款到#{target_order.name}"
        else
          agent = @order.agent
          agent_balance = @order.agent.balance
          @order.update!(arrear: @order.arrear + params[:order][:price].to_f)
          if agent_balance >= 0
            agent.update!(balance: agent.balance + params[:order][:price].to_f,
                          arrear: agent.orders.pluck(:arrear).sum)
          # else
          #   agent.update!(arrear: agent.arrear - params[:order][:price].to_f)
          end
          msg = "成功将#{@order.name}的#{params[:order][:price]}转款到代理商#{agent.full_name}余额中"
        end
        indent = @order.indent
        indent.update!(arrear: indent.orders.pluck(:arrear).sum)
      end
      redirect_to orders_path, success: msg
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
                                  :color, :length, :width, :height, :number, :price, :customer, :delivery_address, :role,
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
