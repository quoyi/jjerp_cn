class OrderCategoriesController < ApplicationController
  before_action :set_order_category, only: [:show, :edit, :update, :destroy]

  # GET /order_categories
  # GET /order_categories.json
  def index
    @order_categories = OrderCategory.all
  end

  # GET /order_categories/1
  # GET /order_categories/1.json
  def show
  end

  # GET /order_categories/new
  def new
    @order_category = OrderCategory.new
  end

  # GET /order_categories/1/edit
  def edit
  end

  # POST /order_categories
  # POST /order_categories.json
  def create
    @order_category = OrderCategory.new(order_category_params)

    respond_to do |format|
      if @order_category.save
        format.html { redirect_to @order_category, notice: 'Order category was successfully created.' }
        format.json { render :show, status: :created, location: @order_category }
      else
        format.html { render :new }
        format.json { render json: @order_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_categories/1
  # PATCH/PUT /order_categories/1.json
  def update
    respond_to do |format|
      if @order_category.update(order_category_params)
        format.html { redirect_to @order_category, notice: 'Order category was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_category }
      else
        format.html { render :edit }
        format.json { render json: @order_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_categories/1
  # DELETE /order_categories/1.json
  def destroy
    @order_category.destroy
    respond_to do |format|
      format.html { redirect_to order_categories_url, notice: 'Order category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_category
      @order_category = OrderCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_category_params
      params.fetch(:order_category, {})
    end
end
