class IndentsController < ApplicationController
  before_action :set_indent, only: [:show, :edit, :update, :destroy]

  # GET /indents
  # GET /indents.json
  def index
    @indents = Indent.all
  end

  # GET /indents/1
  # GET /indents/1.json
  def show
  end

  # GET /indents/new
  def new
    @indent = Indent.new
  end

  # GET /indents/1/edit
  def edit
  end

  # POST /indents
  # POST /indents.json
  def create
    @indent = Indent.new(indent_params)

    respond_to do |format|
      if @indent.save
        format.html { redirect_to @indent, notice: 'Indent was successfully created.' }
        format.json { render :show, status: :created, location: @indent }
      else
        format.html { render :new }
        format.json { render json: @indent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indents/1
  # PATCH/PUT /indents/1.json
  def update
    respond_to do |format|
      if @indent.update(indent_params)
        format.html { redirect_to @indent, notice: 'Indent was successfully updated.' }
        format.json { render :show, status: :ok, location: @indent }
      else
        format.html { render :edit }
        format.json { render json: @indent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indents/1
  # DELETE /indents/1.json
  def destroy
    @indent.destroy
    respond_to do |format|
      format.html { redirect_to indents_url, notice: 'Indent was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indent
      @indent = Indent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indent_params
      params.fetch(:indent, {})
    end
end
