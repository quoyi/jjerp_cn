class IndentsController < ApplicationController
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @agent = Agent.new
    @indent = Indent.new
    @income = @indent.incomes.new
    @indents = Indent.all.order(created_at: :desc)
  end

  # GET /units/1
  # GET /units/1.json
  def show
    @order = Order.new
    @orders = Order.where(indent:@indent).order(created_at: :desc)
  end

  # GET /indents/new
  def new
    @indent = Indent.new
  end

  # GET /indents/1/edit
  def edit
    # @order = Order.new
    # @orders = Order.where(indent:@indent)
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
      redirect_to @indent, notice: "订单编辑成功！"
    else
      redirect_to indents_path, error: "订单编辑失败！"
    end
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    # 需要标记删除，不能真正地删除
    @indent.destroy
    redirect_to indents_path, notice: '订单已删除。'
  end

  def generate
    # binding.pry
    # 查找订单的所有拆单信息，并生成报价单
    redirect_to indents_path, notice: '生成报价单成功！'
  end


  def unpack
    @indents = Indent.joins(:orders).where("orders.status = ?", Order.statuses[:producing]).group("indents.id")
  end

  def package
    @indent = Indent.find(params[:id])
    @order_units = @indent.orders.map(&:units).flatten
    @order_parts = @indent.orders.map(&:parts).flatten
    
    # ids =>
    #    {"1"=>["order_unit_10", "order_unit_11", "order_unit_12", "order_unit_13"],
    # "2"=>["order_unit_14", "order_unit_15", "order_unit_16", "order_unit_17", "order_unit_18"],
    # "3"=>["order_unit_19", "order_unit_20", "order_unit_21", "order_unit_22", "order_unit_23", "order_unit_24"],
    # "4"=>["order_unit_25", "order_part_7", "order_part_8"]}
    # 这些值需存在数据库表package中
    # 打印尺寸需存在users表的default_print_size
    if params[:order_unit_ids].present?
       ids = ActiveSupport::JSON.decode(params[:order_unit_ids]) if params[:order_unit_ids].present?  
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
      @width = 50
    end

    @packages = Indent.find(params[:id]).packages


    respond_to do |format|
      format.html {render :layout => false}
      format.pdf do
        # 打印尺寸毫米（长宽）
        pdf = OrderPdf.new(@length, @width, ids, @indent.id)
        send_data pdf.render, filename: "order_#{@indent.id}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_indent
    @indent = Indent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indent_params
    # if params[:indent][:orders_attributes].present?
    #   params[:indent][:orders_attributes].each_pair do |k, v|
    #   	# v[:name] = params[:indent][:name].to_s
    #     v[:status] = Order.statuses[v[:status]]
    #   end
    # end
    params.require(:indent).permit(:id, :name, :offer_id, :agent_id, :customer, :verify_at, :require_at, :note,
                                  :logistics, :amount, :arrear, :total_history, :total_arrear, :deleted,
                                   orders_attributes: [:id, :order_category_id, :customer, :number, :ply,
                                                       :texture, :color, :length, :width, :height,
                                                       :note, :_destroy])
  end
end
