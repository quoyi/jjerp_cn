class IndentsController < ApplicationController
  include IndentsHelper
  include OffersHelper
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @agent = Agent.new
    @indent = Indent.new
    @income = @indent.incomes.new
    @indents = Indent.all.order(created_at: :desc)
    if params[:start_at].present? && params[:end_at].present?
      @indents = @indents.where("verify_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @indents = @indents.where("verify_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    end

    if params[:agent_id].present?
      @indents = @indents.where(agent_id: params[:agent_id])
    end
  end

  # GET /units/1
  # GET /units/1.json
  def show
    @order = Order.new
    @order_offers = @indent.offers
    @orders = Order.where(indent:@indent).order(created_at: :desc)
  end

  # GET /indents/new
  def new
    @indent = Indent.new
  end

  # GET /indents/1/edit
  def edit
    @agent = Agent.new
    @indent = Indent.find_by_id(params[:id])
  end

  # POST /indents
  # POST /indents.json
  def create
    @indent = Indent.new(indent_params)
    if @indent.save
      redirect_to indents_path, notice: '订单创建成功！'
    else
      redirect_to indents_path, error: '请检查编号是否唯一且数据正确，订单创建失败！'
    end
  end

  # PATCH/PUT /indents/1
  # PATCH/PUT /indents/1.json
  def update
    if @indent.update(indent_params)
      if @indent.status == 'producing'
        @indent.orders.each do |o|
          o.producing!
        end
        msg = "订单: #{@indent.name} 开始生产！"
      else
        msg = "订单编辑成功！"
      end
      redirect_to :back, notice: msg
    else
      redirect_to :back, error: "订单编辑失败！"
    end
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    # 需要标记删除，不能真正地删除
    @indent.destroy
    redirect_to indents_path, notice: '订单已删除。'
  end

  # 生成报价单
  def generate
    # 查找订单的所有拆单信息，并生成报价单
    indent = Indent.find_by_id(params[:id])
    create_offer(indent) if indent
    redirect_to indent_path(indent), notice: '生成报价单成功！'
  end


  def unpack
    @indents = Indent.joins(:orders).where("orders.status = ?", Order.statuses[:producing]).group("indents.id")
  end

  def package
    @indent = Indent.find(params[:id])
    @order_units = @indent.orders.map(&:units).flatten
    @order_parts = @indent.orders.map(&:parts).flatten
    @packages = Indent.find(params[:id]).packages
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
        package = @indent.packages.find_or_create_by(unit_ids: unit_ids.compact.join(','), part_ids: part_ids.compact.join(','))
        package.save!
        Unit.where(id: unit_ids.compact.uniq).update_all(is_printed: true)
        Part.where(id: part_ids.compact.uniq).update_all(is_printed: true)
        packaged_unit_ids = @indent.packages.map(&:unit_ids).join(',').split(',').uniq.map(&:to_i)
        packaged_part_ids = @indent.packages.map(&:part_ids).join(',').split(',').uniq.map(&:to_i)
        unit_ids = @order_units.map(&:id)
        part_ids = @order_parts.map(&:id)
        if (unit_ids - packaged_unit_ids).empty? && (part_ids-packaged_part_ids).empty?
          @indent.packaged!
        end
      end
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
      respond_to do |format|
        format.html {render :layout => false}
        format.pdf do
          # 打印尺寸毫米（长宽）
          pdf = OrderPdf.new(@length, @width, label_size <= 0 ? 1 : label_size , @indent.id)
          send_data pdf.render, filename: "order_#{@indent.id}.pdf",
            type: "application/pdf",
            disposition: "inline"
        end
      end
    elsif params[:format] == 'pdf'
      redirect_to package_indent_path(@indent)
    else
      respond_to do |format|
        format.html
      end
    end


  end

  def not_sent
    @indents = Indent.where(status:Indent.statuses[:packaged])
    @sent = Sent.new()
  end

  # 导出报价单
  def export_offer
    @indent = Indent.find_by_id(params[:id])
    respond_to do |format|
      format.html { redirect_to order_union_path(@indent), notice: '导出成功' }
      format.json { head :no_content }
      format.csv do
        filename = "报价单－" + @indent.name
        response.headers['Content-Type'] = "application/vnd.ms-excel"
        response.headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'
        render text: to_csv(@indent)
      end
      # format.xls do
      #   send_data to_csv(@indent)
      # end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_indent
    @indent = Indent.find(params[:id])
  end

  # 下载报价单并转换为csv
  def to_csv(indent)
    return [] if indent.nil?
    offers = indent.offers
    # make excel using utf8 to open csv file
    # head = 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()
    # head = '\xEF\xBB\xBF'.split(' ').map{|a|a.hex.chr}.join()
    # head = ""
    CSV.generate do |csv|
      # 获取字段名称
      csv << ["总订单号", indent.name, '经销商', indent.agent.full_name,
              '终端客户', indent.customer, '套数', indent.orders.map(&:number).sum()]
      csv << ['下单时间', indent.verify_at, '发货时间', indent.require_at, '状态', indent.status_name,
              '金额￥', offers.map{|o| o.order.number * o.total}.sum()]
      csv << ['序号', '类型', '名称', '单价￥', '单位', '数量', '备注', '总价￥']
      offers.group_by(&:order_id).each_pair do |order_id, offers|
        offers.each_with_index do |offer, index|
          values = []
          values << index + 1
          values << offer.item_type_name
          values << offer.item_name
          values << offer.price
          values << offer.uom
          values << offer.number
          values << offer.note
          values << offer.total
          csv << values
        end
        order = offers.first.order
        order_total = offers.map(&:total).sum()
        orders_total = order_total * order.number
        csv << ['子订单号', order.name, '单套合计￥', order_total, '单项套数', order.number,
                '项目合计￥', orders_total]
        csv << ['', '', '', '', '', '', '', '']
      end
    end.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indent_params
    # if params[:indent][:orders_attributes].present?
    #   params[:indent][:orders_attributes].each_pair do |k, v|
    #     # v[:name] = params[:indent][:name].to_s
    #     v[:status] = Order.statuses[v[:status]]
    #   end
    # end
    params.require(:indent).permit(:id, :name, :offer_id, :agent_id, :customer, :verify_at, :require_at, :note,
                                   :logistics, :amount, :arrear, :total_history, :total_arrear, :deleted, :status,
                                   orders_attributes: [:id, :order_category_id, :customer, :number, :ply,
                                                       :texture, :color, :length, :width, :height,
                                                       :note, :_destroy])
  end
end
