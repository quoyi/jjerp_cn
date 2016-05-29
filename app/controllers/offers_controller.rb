class OffersController < ApplicationController
  include OffersHelper
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  # GET /offers
  # GET /offers.json
  def index
    @offers = Offer.where(deleted: false)
  end

  # GET /offers/1
  # GET /offers/1.json
  def show
  end

  # GET /offers/new
  def new
    @offer = Offer.new
  end

  # GET /offers/1/edit
  def edit
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = Offer.new(offer_params)

    respond_to do |format|
      if @offer.save
        format.html { redirect_to @offer, notice: 'Offer was successfully created.' }
        format.json { render :show, status: :created, location: @offer }
      else
        format.html { render :new }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /offers/1
  # PATCH/PUT /offers/1.json
  def update
    respond_to do |format|
      if @offer.update(offer_params)
        format.html { redirect_to @offer, notice: 'Offer was successfully updated.' }
        format.json { render :show, status: :ok, location: @offer }
      else
        format.html { render :edit }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.json
  def destroy
    @offer.update_attributes(deleted: true)
    redirect_to offers_url, notice: '拆单记录已删除。'
  end

  def generate
    binding.pry
    # 通过页面传递的indent_id 查找对应的订单
    @indent = Indent.find_by_id(params[:indent_id])
    @offer = @indent.offers.new
    # @units = @indent.orders.units
    # @parts = @indent.orders.parts
    # @crafts = @indent.orders.crafts
    @offer.total = @indent.offers.map(&:total).sum
    # 查找订单的所有拆单信息，并生成报价单
    redirect_to indents_path, notice: '生成报价单成功！'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_offer
      @offer = Offer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def offer_params
      params.require(:offer).permit(:indent_id, :order_id, :display, :item, :item_name,
                                    :uom, :number, :price, :sum, :total, :note, :deleted)
    end
end
