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
    @orders = Order.all.order(created_at: :desc)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @orders = @orders.joins(:indent).where("indents.verify_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @orders = @orders.joins(:indent).where("indents.verify_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end
    # 搜索条件 代理商ID
    @orders = @orders.joins(:indent).where("indents.agent_id = ?",params[:agent_id]) if params[:agent_id].present?
    respond_to do |format|
      format.html 
      format.xls do
        filename = Time.now.strftime("%Y%m%d%H%M%S%L") + ".xls"
        export_orders(filename, @orders, params[:start_at], params[:end_at])
        send_file "#{Rails.root}/public/excels/" + filename, type: 'text/xls; charset=utf-8'
      end
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
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
    @order = Order.new(order_params)
    if @order.save
      # 子订单保存后，更新订单、子订单的价格合计
      update_order_and_indent(@order)
      # 生成报价单，更新总订单、子订单状态
      create_offer(@order)
      update_order_status(@order.reload)
      # update_indent_status(@order.indent)
      
      redirect_to :back, notice: '子订单创建成功！'
    else
      redirect_to :back, error: '子订单创建失败！'
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    return redirect_to @order, error: '请求无效！请检查数据是否有效。' unless params[:order]
    if @order.update(order_params)
      # 自定义报价时，查找或创建板料，防止找不到板料
      @order.units.where(is_custom: true).each do |unit|
        Material.find_or_create_by(ply: unit.ply, texture: unit.texture, color: unit.color, full_name: "#{unit.ply_name}-#{unit.texture_name}-#{unit.color_name}", buy: 0, price: unit.price)
      end
      # 子订单更新后，更新总订单、子订单的价格合计
      update_order_and_indent(@order)
      # 生成报价单，更新总订单、子订单状态
      create_offer(@order)
      update_order_status(@order.reload)
      # update_indent_status(@order.indent)
      redirect_to indent_path(@order.indent), notice: '子订单编辑成功！'
    else
      redirect_to :back, error: '子订单编辑失败！请仔细检查后再提交。'
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    redirect_to orders_url, notice: '子订单已删除。'
  end

  #生产任务
  def producing
    @orders = Order.producing
  end

  # 导入文件，或手工输入
  def import
    msg = import_order_units(params[:file], @order.name)
    # 订单修改后，更新订单、子订单的价格合计
    update_order_and_indent(@order)
    create_offer(@order)
    update_order_status(@order.reload)
    # update_indent_status(@order.indent)
    redirect_to :back, notice: msg
    # 有上传文件时
    # if params[:file].original_filename !~ /.csv$/
    #   return redirect_to order_path(@order), error: '文件格式不正确！'
    # else
    #   msg = import_order_units(params[:file], @order.name)
    #   if msg == "success"
    #     return redirect_to order_path(@order), notice: "拆单导入成功"
    #   else
    #     return redirect_to order_path(@order), alert: msg
    #   end
    # end
  end

  # 自定义报价
  def custom_offer
    @indent = @order.indent
    @unit = Unit.new
    @material = Material.new
    @part_category = PartCategory.new
  end

  # 未打包
  def unpack
    @orders = Order.where(status: Order.statuses[:producing])
    @orders.each do |order|
      if order.status == "producing" && order.units.size == 0 && order.parts.size == 0 && order.crafts.size != 0
        order.packaged!
        update_order_status(order)
      end
    end
    @orders = @orders.reload#.where(status: Order.statuses[:producing])
  end

  # GET 打包页面
  def package
    @order = Order.find_by_id(params[:id])
    @order_units = @order.units
    @order_parts = @order.parts
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
        part_ids = values.map do |v|
          if v =~ /order_part/
            id = v.gsub(/order_part_/,'')
            id
          end
        end
        # 保存包装记录
        package = @order.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','), part_ids: part_ids.compact.join(','))
        package.save!
        # 更新包装状态（已打印）
        Unit.where(id: unit_ids.compact.uniq).update_all(is_printed: true)
        Part.where(id: part_ids.compact.uniq).update_all(is_printed: true)
        # 查出已打包（已保存）的部件、配件id，用于界面显示
        packaged_unit_ids = @order.packages.map(&:unit_ids).join(',').split(',').uniq.map(&:to_i)
        packaged_part_ids = @order.packages.map(&:part_ids).join(',').split(',').uniq.map(&:to_i)
        unit_ids = @order_units.map(&:id)
        part_ids = @order_parts.map(&:id)
        # 订单的所有部件、配件均已打包，修改订单的状态为“已打包”
        if (unit_ids - packaged_unit_ids).empty? && (part_ids-packaged_part_ids).empty?
          @order.packaged!
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


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:indent_id, :name, :order_category_id, :ply, :texture,
                                  :color, :length, :width, :height, :number, :price,
                                  :status, :oftype, :note, :deleted, :file, :_destroy, :is_use_order_material,
                                  units_attributes: [:id, :full_name, :number, :ply, :texture, :color, :is_custom,
                                                     :length, :width, :size, :uom, :price, :note, :_destroy],
                                  parts_attributes: [:id, :part_category_id, :order_id,
                                                     :name, :buy, :price, :store, :uom, :number, :brand,
                                                     :supply_id, :deleted, :_destroy],
                                  crafts_attributes: [:id, :order_id, :full_name, :uom,
                                                      :price, :number, :note, :status, :deleted, :_destroy])
  end
end
