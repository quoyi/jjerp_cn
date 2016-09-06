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
    @order = Order.new
    @income = Income.new(username: current_user.name, income_at: Time.now)
    @orders = Order.all.order(created_at: :desc)
    @start_at = Date.today.beginning_of_month.to_s
    @end_at = Date.today.end_of_month.to_s
    @province = '420000'
    @city = '420100'
    @district = '--地区--'
    search = ''
    if params[:province].present?
      @province = params[:province]
      search << ChinaCity.get(@province)
    end

    if params[:city].present?
      @city = params[:city]
      search << ChinaCity.get(@city)
    end

    if params[:district].present?
      @district = params[:district]
      search << ChinaCity.get(@district)
    end

    @orders = @orders.where("delivery_address like :keyword",keyword: "%#{search}%")

    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
    end
    @orders = @orders.joins(:indent).where("indents.verify_at between ? and ?", @start_at, @end_at)
    # 搜索条件 代理商ID
    @orders = @orders.joins(:indent).where("indents.agent_id = ?",params[:agent_id]) if params[:agent_id].present?
    respond_to do |format|
      format.html 
      format.xls do
        filename = Time.now.strftime("%Y%m%d%H%M%S%L") + ".xls"
        export_orders(filename, @orders, params[:start_at], params[:end_at])
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
    Order.transaction do
      @order = Order.new(order_params)
      # 保存新建子订单之前，先获取总订单 （原）金额，后面需要减 （原）金额
      origin_indent_amount = @order.indent.orders.pluck(:price).sum
      @order.save!

      # 更新总订单金额
      indent = @order.indent
      # 总订单 -- 所有子订单金额合计
      indent_amount = indent.orders.pluck(:price).sum
      # 总订单 -- 所有收入金额合计
      indent_income = indent.incomes.pluck(:money).sum
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent_amount, arrear: indent_amount - indent_income, status: Indent.statuses[:offering])

      # 更新代理商 历史欠款合计、历史订单合计
      agent = indent.agent
      agent.update!(arrear: agent.arrear + indent.amount - origin_indent_amount, history: agent.history + indent.amount - origin_indent_amount)
    end
    
    if @order
      redirect_to :back, notice: '子订单创建成功！'
    else
      redirect_to :back, error: '子订单创建失败！'
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    return redirect_to @order, error: '请求无效！请检查数据是否有效。' unless params[:order]
    Order.transaction do
      # 更新之前，先获取总订单 （原）金额，后面需要减 （原）金额
      origin_indent_amount = @order.indent.orders.pluck(:price).sum

      @order.update!(order_params)
      # 自定义报价时，查找或创建板料，防止找不到板料
      @order.units.where(is_custom: true).each do |unit|
        Material.find_or_create_by(ply: unit.ply, texture: unit.texture, color: unit.color, full_name: "#{unit.ply_name}-#{unit.texture_name}-#{unit.color_name}", buy: 0, price: unit.price)
      end

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
      @order.update!(price: sum_units + sum_parts + sum_crafts)

      # 更新总订单金额
      indent = @order.indent
      # 总订单 -- 所有子订单 （新）金额合计
      indent_amount = indent.orders.pluck(:price).sum
      # 总订单 -- 所有收入 （新）金额合计
      indent_income = indent.incomes.pluck(:money).sum
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent_amount, arrear: indent_amount - indent_income)

      # 更新代理商 历史欠款合计、历史订单合计
      agent = indent.agent
      agent.update!(arrear: agent.arrear + indent.amount - origin_indent_amount, 
                    history: agent.history + indent.amount - origin_indent_amount)

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
      # 更新总订单金额
      indent = @order.indent
      # 总订单 -- 所有子订单 （新）金额合计
      indent_amount = indent.orders.pluck(:price).sum
      # 总订单 -- 所有收入 （新）金额合计
      indent_income = indent.incomes.pluck(:money).sum
      # 总订单： 金额合计 = 所有子订单金额合计，  欠款合计 = 所有子订单金额合计 - 所有收入金额合计
      indent.update!(amount: indent_amount - @order.price, arrear: indent_amount - @order.price - indent_income)

      # 更新代理商 历史欠款合计、历史订单合计
      agent = indent.agent
      agent.update!(arrear: agent.arrear - @order.price, 
                    history: agent.history - @order.price)

      # 生成报价单
      create_offer(@order)
      # 修改子订单、总订单的状态
      update_order_status(@order.reload)
      @order.destroy!
    end
    binding.pry
    redirect_to orders_url, notice: '子订单已删除。'
  end

  # 未发货
  def not_sent
    @orders = Order.where(status: Order.statuses[:packaged])
    @indents = @orders.group(:indent_id).map(&:indent)
    @sent = Sent.new()
  end

  #生产任务
  def producing
    @orders = Order.where(status: Order.statuses[:producing])
  end

  # 导入文件，或手工输入
  def import
    Order.transaction do
      # 更新之前，先获取总订单 （原）金额，后面需要减 （原）金额
      origin_indent_amount = @order.indent.orders.pluck(:price).sum

      msg = import_order_units(params[:file], @order.name)

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
      @order.update!(price: sum_units + sum_parts + sum_crafts)

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
  end

  # 已打包
  # GET /orders/packaged
  def packaged
    @orders = Order.where(status: Order.statuses[:packaged])
  end

  # GET 打包页面
  # orders/1/package
  def package
    # 按照顺序查找： 指定编号、指定ID、第一个（防止打印页面报错）
    if params[:name].present?
      @order = Order.find_by(name: params[:name])
    elsif params[:id].present?
      @order = Order.find_by_id(params[:id])
    else
      @order = Order.order(created_at: :asc).first
    end
    @order_units = @order.units
    # @order_parts = @order.parts
    @packages = @order.packages
    # @indent = Indent.find(params[:id])
    # @order_units = @indent.orders.map(&:units).flatten
    # @order_parts = @indent.orders.map(&:parts).flatten
    # @packages = Indent.find(params[:id]).packages
    # ids =>
    #    {"1"=>["order_unit_10", "order_unit_11", "order_unit_12", "order_unit_13"],
    # "2"=>["order_unit_14", "order_unit_15", "order_unit_16", "order_unit_17", "order_unit_18"],
    # "3"=>["order_unit_19", "order_unit_20", "order_unit_21", "order_unit_22", "order_unit_23", "order_unit_24"],
    # "4"=>["order_unit_25", "order_part_7", "order_part_8"]}
    # 这些值需存在数据库表package中
    # 打印尺寸需存在users表的default_print_size
    if params[:order_unit_ids].present? &&  params[:order_unit_ids] != "{}"
      label_size = params[:order_label_size].to_i if params[:order_label_size]
      ids = ActiveSupport::JSON.decode(params[:order_unit_ids])

      ids.each_pair do |key,values|
        # package.print_size =
        unit_ids = values.map  do |v|
          if v =~ /order_unit/
            id = v.gsub(/order_unit_/,'')
            id
          end
        end
        # part_ids = values.map do |v|
        #   if v =~ /order_part/
        #     id = v.gsub(/order_part_/,'')
        #     id
        #   end
        # end
        # 保存包装记录
        # package = @order.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','), part_ids: part_ids.compact.join(','))
        package = @order.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','))
        package.label_size = label_size
        package.save!
        # 更新包装状态（已打印）
        Unit.where(id: unit_ids.compact.uniq).update_all(is_printed: true)
        # Part.where(id: part_ids.compact.uniq).update_all(is_printed: true)
        # 查出已打包（已保存）的部件、配件id，用于界面显示
        packaged_unit_ids = @order.packages.map(&:unit_ids).join(',').split(',').uniq.map(&:to_i)
        # packaged_part_ids = @order.packages.map(&:part_ids).join(',').split(',').uniq.map(&:to_i)
        unit_ids = @order_units.map(&:id)
        # part_ids = @order_parts.map(&:id)
        # 订单的所有部件、配件均已打包，修改订单的状态为“已打包”
        if (unit_ids - packaged_unit_ids).empty?
          @order.packaged!
          update_order_status(@order)
        end
      end

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
  end

  # 重新打印
  # POST /orders/1/reprint
  def reprint
    @order = Order.find_by_id(params[:id])
    label_size = @order.packages.map(&:label_size).sum
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
        pdf = OrderPdf.new(@length, @width, label_size <= 0 ? 1 : label_size , @order.id)
        send_data pdf.render, filename: "order_#{@order.id}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
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
                                  :color, :length, :width, :height, :number, :price, :customer, :delivery_address,
                                  :status, :oftype, :note, :deleted, :file, :_destroy, :is_use_order_material,
                                  units_attributes: [:id, :full_name, :number, :ply, :texture, :color, :is_custom,
                                                     :length, :width, :size, :uom, :price, :note, :_destroy],
                                  parts_attributes: [:id, :part_category_id, :order_id,
                                                     :name, :buy, :price, :store, :uom, :number, :brand, :note,
                                                     :supply_id, :deleted, :_destroy],
                                  crafts_attributes: [:id, :order_id, :full_name, :uom, :craft_category_id,
                                                      :price, :number, :note, :status, :deleted, :_destroy])
  end
end
