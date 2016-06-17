class SentsController < ApplicationController
  before_action :set_sent, only: [:show, :edit, :update, :destroy]

  # GET /sents
  # GET /sents.json
  def index
    @sents = Sent.all
  end

  # GET /sents/1
  # GET /sents/1.json
  def show
  end

  # GET /sents/new
  def new
    @sent = Sent.new
  end

  # GET /sents/1/edit
  def edit
  end

  # POST /sents
  # POST /sents.json
  def create
    @sent = Sent.new(sent_params)

    respond_to do |format|
      if @sent.save
        format.html { redirect_to @sent, notice: 'Sent was successfully created.' }
        format.json { render :show, status: :created, location: @sent }
      else
        format.html { render :new }
        format.json { render json: @sent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sents/1
  # PATCH/PUT /sents/1.json
  def update
    respond_to do |format|
      if @sent.update(sent_params)
        format.html { redirect_to @sent, notice: 'Sent was successfully updated.' }
        format.json { render :show, status: :ok, location: @sent }
      else
        format.html { render :edit }
        format.json { render json: @sent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sents/1
  # DELETE /sents/1.json
  def destroy
    @sent.destroy
    respond_to do |format|
      format.html { redirect_to sents_url, notice: 'Sent was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sent
      @sent = Sent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sent_params
      params.require(:sent).permit(:indent_id, :name, :sent_at, :area, :receiver, :contact, :cupboard, :robe, :door, :part, :collection, :collection, :logistics, :logistics_code)
    end
end
