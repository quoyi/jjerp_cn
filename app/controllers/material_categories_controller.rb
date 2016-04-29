class MaterialCategoriesController < ApplicationController
  before_action :set_material_category, only: [:show, :edit, :update, :destroy]

  # GET /material_categories
  # GET /material_categories.json
  def index
    @material_categories = MaterialCategory.all
  end

  # GET /material_categories/1
  # GET /material_categories/1.json
  def show
  end

  # GET /material_categories/new
  def new
    @material_category = MaterialCategory.new
  end

  # GET /material_categories/1/edit
  def edit
  end

  # POST /material_categories
  # POST /material_categories.json
  def create
    @material_category = MaterialCategory.new(material_category_params)

    respond_to do |format|
      if @material_category.save
        format.html { redirect_to @material_category, notice: 'Material category was successfully created.' }
        format.json { render :show, status: :created, location: @material_category }
      else
        format.html { render :new }
        format.json { render json: @material_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /material_categories/1
  # PATCH/PUT /material_categories/1.json
  def update
    respond_to do |format|
      if @material_category.update(material_category_params)
        format.html { redirect_to @material_category, notice: 'Material category was successfully updated.' }
        format.json { render :show, status: :ok, location: @material_category }
      else
        format.html { render :edit }
        format.json { render json: @material_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /material_categories/1
  # DELETE /material_categories/1.json
  def destroy
    @material_category.destroy
    respond_to do |format|
      format.html { redirect_to material_categories_url, notice: 'Material category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_category
      @material_category = MaterialCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def material_category_params
      params.fetch(:material_category, {})
    end
end
