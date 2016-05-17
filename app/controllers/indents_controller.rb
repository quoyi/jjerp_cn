class IndentsController < ApplicationController
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @indent = Indent.new
    @indents = Indent.where(deleted:false)
  end

  # GET /indents/new
  def new
    @indent = Indent.new
    binding.pry
  end

  # GET /indents/1/edit
  def edit
  end

  # POST /indents
  # POST /indents.json
  def create
    @indent = Indent.new(indent_params)
    binding.pry
    if @indent.save
      redirect_to indents_path, notice: '订单创建成功！'
    else
      redirect_to indents_path, error: '订单创建失败！'
    end
  end

  # PATCH/PUT /indents/1
  # PATCH/PUT /indents/1.json
  def update
    if @indent.update(indent_params)
      redirect_to indents_path, notice: "订单编辑成功！"
    else
      redirect_to indents_path, error: "订单编辑失败！"
    end
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    # 需要标记删除，不能真正地删除
    @indent.update_attributes(deleted: true)
    redirect_to indents_path, notice: '订单已删除。'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_indent
    @indent = Indent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indent_params
    params.require(:indent).permit(:name, :agent_id, :customer, :verify_at, :require_at, :note,
                                   order_attributes: [:id, :order_category_id, :customer, :ply, :number,
                                                      :texture, :color, :length, :width, :height,:status, :note])
  end
end
