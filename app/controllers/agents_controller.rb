class AgentsController < ApplicationController
  before_action :set_agent, only: %i[show edit update destroy]

  # GET /agents
  # GET /agents.json
  def index
    tmp_agent = Agent.order(:created_at).last
    tmp_name = tmp_agent.present? ? tmp_agent.name.gsub('DL', '').to_i + 1 : 1
    @agent = Agent.new(name: 'DL'.upcase + tmp_name.to_s.rjust(4, '0'))
    @agents = Agent.where(deleted: false).order(created_at: :desc)
    # 代理商列表页面查询用
    @agent_full_name, @agent_contacts, @agent_mobile = 3.times.map { '' }
    # 提供给 select2 查询
    if params[:term].present?
      @agents = @agents.where("#{params[:oftype]} like '%#{params[:term]}%'")
    else # 提供给 代理商 页面查询条件
      if params[:full_name].present?
        @agent_full_name = Agent.find_by(id: params[:full_name]).try(:full_name)
        # agent = Agent.find_by(id: params[:full_name])
        # @agent_full_name = [agent.id, agent.full_name]
        # @agents = @agents.where("id = #{params[:full_name]} and full_name like '%#{params[:term]}%'}")
        @agents = @agents.where("full_name like '%#{@agent_full_name}%'")
      end
      if params[:contacts].present?
        # agent = Agent.find_by(id: params[:contacts])
        @agent_contacts = Agent.find_by(id: params[:contacts]).try(:contacts)
        @agents = @agents.where("contacts like '%#{@agent_contacts}%'")
      end
      if params[:mobile].present?
        # agent = Agent.find_by(id: params[:mobile])
        @agent_mobile = Agent.find_by(id: params[:mobile]).try(:mobile)
        @agents = @agents.where("mobile like '%#{@agent_mobile}%'")
      end
    end

    # @agents = @agents.where("full_name like :keyword", keyword: "%#{params[:term]}%") if params[:term].present?
    # 配件统计信息(将电话号码相同的所有代理商视为同一个代理商，分组统计)
    agents_arr = []
    @agents.group_by(&:mobile).each_pair do |key, value|
      agent = Agent.find_by(mobile: key)
      number = 0
      total = 0
      value.each do |_agent|
        number += agent.orders.count
        total += agent.orders.pluck(:price).sum
      end
      agents_arr << { name: agent.full_name, number: number, money: total }
    end
    @agents_arr = agents_arr.sort_by { |m| m[:money] }
    @agents_arr = @agents_arr.reverse if params[:sort].present? && params[:sort] == 'desc'

    respond_to do |format|
      format.html { @agents = @agents.page(params[:page]) }
      format.json do
        if params[:page]
          per = 6
          size = @agents.offset((params[:page].to_i - 1) * per).size # 剩下的记录条数
          result = @agents.offset((params[:page].to_i - 1) * per).limit(per) # 当前显示的所有记录
          if params[:oftype].present?
            result = result.map { |ac| { id: ac.id, text: ac.full_name } } if params[:oftype] == 'full_name'
            result = result.map { |ac| { id: ac.id, text: ac.contacts } } if params[:oftype] == 'contacts'
            result = result.map { |ac| { id: ac.id, text: ac.mobile } } if params[:oftype] == 'mobile'
          end
          # result = result << {id: "", text: '全部'} if params[:page].to_i == 1
        end
        render json: { agents: result.reverse, total: size }
      end
    end
  end

  # GET /agents/1
  # GET /agents/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @agent }
    end
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
    # @agent.province = ChinaCity.get(agent_params[:province])
    # @agent.city = ChinaCity.get(agent_params[:city])
    # @agent.district = ChinaCity.get(agent_params[:district])
    if @agent.save
      redirect_to :back, notice: '代理商创建成功！'
    else
      redirect_to :back, error: '代理商创建失败！'
    end
  end

  # PATCH/PUT /agents/1
  # PATCH/PUT /agents/1.json
  def update
    if @agent.update(agent_params)
      redirect_to agents_path, notice: '代理商编辑成功！'
    else
      redirect_to agents_path, error: '代理商编辑失败！'
    end
  end

  # DELETE /agents/1
  # DELETE /agents/1.json
  def destroy
    @agent.update_attributes(deleted: true)
    redirect_to agents_url, notice: '代理商已删除。'
  end

  # ajax 搜索指定代理商
  def search
    @agents = Agent.where(province: params[:province])
    @agents = @agents.where(city: params[:city]) unless params[:city].blank?
    @agents = @agents.where(district: params[:district]) unless params[:district].blank?
    render json: @agents
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_agent
    @agent = Agent.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agent_params
    params.require(:agent).permit(:name, :province, :city, :district, :town, :address, :delivery_address,
                                  :full_name, :contacts, :mobile, :e_account, :fax, :email,
                                  :wechar, :logistics, :order_condition, :send_condition,
                                  :cycle, :note, :deleted, :history, :balance)
  end
end
