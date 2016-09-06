class IncomesController < ApplicationController
  include BanksHelper
  before_action :set_income, only: [:show, :edit, :update, :destroy]

  # GET /incomes
  # GET /incomes.json
  def index

    @incomes = Income.all

    if params[:indent_id].present? 
      indent = Indent.find(params[:indent_id])
      @incomes =@incomes.where(order_id: indent.orders.pluck(:id))
    end

    @income = Income.new(username: current_user.name, income_at: Time.now)

  end

  # GET /incomes/1
  # GET /incomes/1.json
  def show
  end

  # GET /incomes/new
  def new
    @income = Income.new(username: current_user.name, income_at: Time.now)
  end

  # GET /incomes/1/edit
  def edit
  end

  # POST /incomes
  # POST /incomes.json
  def create
    begin
      Income.transaction do
        @income = Income.new(income_params)
        @income.save!
        # 更新总订单 欠款合计
        indent = @income.order.indent
        indent.update!(arrear: indent.arrear - @income.money)
        agent = indent.agent
        new_arrear = agent.arrear - @income.money
        if new_arrear <= 0 
          agent.update!(arrear: 0, balance: - new_arrear)
        else
          agent.update!(arrear: new_arrear)
        end

        # 修改银行卡的收入信息
        updateIncomeExpend(income_params, 0)
        balance = income_params[:money].to_f - @income.order.price.to_f
        if balance > 0
          agent = @income.order.agent
          order_name = @income.order.name
          order_create_time = @income.order.created_at
          agent.orders.where("created_at >= ?", order_create_time).each do |order|
            next if order.income_status == '全款' || balance <= 0
            arrear = order.price.to_f - order.incomes.pluck(:money).sum
            if balance - arrear > 0
              balance = balance - arrear
            else
              arrear = balance
              balance = 0
            end
            income = order.incomes.new(money: arrear, username: current_user.name, income_at: Time.now, note: "来自订单#{order_name}")
            income.save!
          end

          if balance > 0
            agent.balance +=  balance
            agent.note =  "来自订单#{order_name}"
            agent.save!
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => exception
    end
    
    
    if @income
      redirect_to :back, notice: '收入记录创建成功！'
    else
      redirect_to :back, error: '收入记录创建失败！'
    end
  end

  # PATCH/PUT /incomes/1
  # PATCH/PUT /incomes/1.json
  def update
    if @income.update(income_params)
      # 修改银行卡的收入信息
      updateIncomeExpend(income_params, 0)
      redirect_to incomes_path, notice: '收入记录编辑成功！'
    else
      redirect_to incomes_path, error: '收入记录编辑失败！'
    end
  end

  # DELETE /incomes/1
  # DELETE /incomes/1.json
  def destroy
    @income.update(deleted: true)
    # @income.destroy
    redirect_to incomes_path, notice: '收入记录已删除。'
  end


  def stat
    @incomes = Income.all
    @expends = Expend.all

    if params[:start_at].present? && params[:end_at].present?
      @incomes = @incomes.where("income_at between ? and ?", params[:start_at], params[:end_at])
      @expends = @expends.where("expend_at between ? and ?", params[:start_at], params[:end_at])
    elsif params[:start_at].present? || params[:end_at].present?
      @incomes = @incomes.where("income_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
      @expends = @expends.where("expend_at = ? ", params[:start_at].present? ? params[:start_at] : params[:end_at])
    elsif !params[:start_at].present? && !params[:end_at].present?
      beginning_month = Date.today.beginning_of_month
      end_month = Date.today.end_of_month
      @incomes = @incomes.where("income_at between ? and ?", beginning_month, end_month)
      @expends = @expends.where("expend_at between ? and ?", beginning_month, end_month)
    end

    if params[:bank_id].present?
      @incomes = @incomes.where(bank_id: params[:bank_id])
      @expends = @expends.where(bank_id: params[:bank_id])
    end

    @incomes = @incomes.order(income_at: :desc)
    @expends = @expends.order(expend_at: :desc)

    @incomes_expends = @incomes.to_a + @expends.to_a

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_income
      @income = Income.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def income_params
      params.require(:income).permit(:name, :reason, :indent_id, :order_id, :money, :username,
                                     :income_at, :status, :note, :bank_id, :deleted)
    end
end
