class UnitCategoriesController < ApplicationController
  before_action :set_unit_category, only: [:show, :edit, :update, :destroy]

  # GET /unit_categories
  # GET /unit_categories.json
  def index
    @unit_categories = UnitCategory.all
  end

  # GET /unit_categories/1
  # GET /unit_categories/1.json
  def show
  end

  # GET /unit_categories/new
  def new
    @unit_category = UnitCategory.new
  end

  # GET /unit_categories/1/edit
  def edit
  end

  # POST /unit_categories
  # POST /unit_categories.json
  def create
    @unit_category = UnitCategory.new(unit_category_params)

    respond_to do |format|
      if @unit_category.save
        format.html { redirect_to @unit_category, notice: 'Unit category was successfully created.' }
        format.json { render :show, status: :created, location: @unit_category }
      else
        format.html { render :new }
        format.json { render json: @unit_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unit_categories/1
  # PATCH/PUT /unit_categories/1.json
  def update
    respond_to do |format|
      if @unit_category.update(unit_category_params)
        format.html { redirect_to @unit_category, notice: 'Unit category was successfully updated.' }
        format.json { render :show, status: :ok, location: @unit_category }
      else
        format.html { render :edit }
        format.json { render json: @unit_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_categories/1
  # DELETE /unit_categories/1.json
  def destroy
    @unit_category.destroy
    respond_to do |format|
      format.html { redirect_to unit_categories_url, notice: 'Unit category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit_category
      @unit_category = UnitCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_category_params
      params.fetch(:unit_category, {})
    end
end
