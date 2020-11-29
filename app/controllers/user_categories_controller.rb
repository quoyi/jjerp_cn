class UserCategoriesController < ApplicationController
  before_action :set_user_category, only: %i[show edit update destroy]

  # GET /user_categories
  # GET /user_categories.json
  def index
    @user_categories = UserCategory.all
  end

  # GET /user_categories/1
  # GET /user_categories/1.json
  def show
  end

  # GET /user_categories/new
  def new
    @user_category = UserCategory.new
  end

  # GET /user_categories/1/edit
  def edit
  end

  # POST /user_categories
  # POST /user_categories.json
  def create
    @user_category = UserCategory.new(user_category_params)

    respond_to do |format|
      if @user_category.save
        format.html { redirect_to @user_category, notice: 'User category was successfully created.' }
        format.json { render :show, status: :created, location: @user_category }
      else
        format.html { render :new }
        format.json { render json: @user_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_categories/1
  # PATCH/PUT /user_categories/1.json
  def update
    respond_to do |format|
      if @user_category.update(user_category_params)
        format.html { redirect_to @user_category, notice: 'User category was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_category }
      else
        format.html { render :edit }
        format.json { render json: @user_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_categories/1
  # DELETE /user_categories/1.json
  def destroy
    @user_category.destroy
    respond_to do |format|
      format.html { redirect_to user_categories_url, notice: 'User category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_category
    @user_category = UserCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_category_params
    params.fetch(:user_category, {})
  end
end
