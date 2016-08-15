class SentListsController < ApplicationController
  before_action :set_sent_list, only: [:show, :edit, :update, :destroy]

  # GET /sent_lists
  # GET /sent_lists.json
  def index
    @sent_lists = SentList.all
  end

  # GET /sent_lists/1
  # GET /sent_lists/1.json
  def show
  end

  # GET /sent_lists/new
  def new
    @sent_list = SentList.new
  end

  # GET /sent_lists/1/edit
  def edit
  end

  # POST /sent_lists
  # POST /sent_lists.json
  def create
    @sent_list = SentList.new(sent_list_params)

    respond_to do |format|
      if @sent_list.save
        format.html { redirect_to @sent_list, notice: 'Sent list was successfully created.' }
        format.json { render :show, status: :created, location: @sent_list }
      else
        format.html { render :new }
        format.json { render json: @sent_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sent_lists/1
  # PATCH/PUT /sent_lists/1.json
  def update
    respond_to do |format|
      if @sent_list.update(sent_list_params)
        format.html { redirect_to @sent_list, notice: 'Sent list was successfully updated.' }
        format.json { render :show, status: :ok, location: @sent_list }
      else
        format.html { render :edit }
        format.json { render json: @sent_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sent_lists/1
  # DELETE /sent_lists/1.json
  def destroy
    @sent_list.destroy
    respond_to do |format|
      format.html { redirect_to sent_lists_url, notice: 'Sent list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sent_list
      @sent_list = SentList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sent_list_params
      params.require(:sent_list).permit(:name, :total, :created_by, :deleted)
    end
end
