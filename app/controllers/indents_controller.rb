class IndentsController < ApplicationController
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @agent = Agent.new
    @indent = Indent.new
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
