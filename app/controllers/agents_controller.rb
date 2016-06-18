class AgentsController < ApplicationController
  before_action :set_agent, only: [:show, :edit, :update, :destroy]

  # GET /agents
  # GET /agents.json
  def index
    @agent = Agent.new
    @agents = Agent.where(deleted: false)

    if params[:term]
      search = params[:term]
      @agents = @agents.where("full_name like :keyword", keyword: "%#{search}%")
    end

    respond_to do |format|
      format.html
      format.json { render json: {:agents => (@agents.map{|ac| {id: ac.id, text: ac.full_name}} << {id: nil, text: '全部'}).reverse, :total => @agents.size} }
    end

  end

  # GET /agents/1
  # GET /agents/1.json
  def show
  end

  # GET /agents/new
  def new
    @agent = Agent.new
  end

  # GET /agents/1/edit
  def edit
  end

  # POST /agents
  # POST /agents.json
  def create
    @agent = Agent.new(agent_params)
    if @agent.save
      redirect_to agents_path, notice: '经销商创建成功！'
    else
      render agents_path, error: '经销商创建失败！'
    end
  end

  # PATCH/PUT /agents/1
  # PATCH/PUT /agents/1.json
  def update
    if @agent.update(agent_params)
      redirect_to agents_path, notice: '经销商编辑成功！'
    else
      render agents_path, error: '经销商编辑失败！'
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.json
  def destroy
    @agent.update_attributes(deleted: true)
    redirect_to agents_url, notice: '经销商已删除。'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent
      @agent = Agent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agent_params
      params.require(:agent).permit(:name, :province_id, :city_id, :district_id, :address,
                                    :full_name, :contacts, :mobile, :e_account, :fax, :email,
                                    :wechar, :logistics, :order_condition, :send_condition,
                                    :cycle, :note, :deleted)
    end
end
