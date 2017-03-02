class SentListsController < ApplicationController
  include OrdersHelper
  include SentListsHelper
  before_action :set_sent_list, only: [:show, :edit, :update, :destroy, :download]

  # GET /sent_lists
  # GET /sent_lists.json
  def index
    @sent_lists = SentList.all.order(created_at: :desc)
    # 判断搜索条件 起始时间 -- 结束时间
    if params[:start_at].present? && params[:end_at].present?
      @start_at = params[:start_at]
      @end_at = params[:end_at]
      @sent_lists = @sent_lists.where("created_at between ? and ?", @start_at, @end_at).order(:id)
    end
    
    if params[:agent_id].present?
      @agent_id = params[:agent_id]
      @orders = Order.where(agent_id: @agent_id)
      @indents = Indent.where(agent_id: @agent_id)
      @sents = Sent.where(owner: @orders || @indents)
      @sent_lists = @sent_lists.where(id: @sents.pluck(:sent_list_id))
    end
    
    @sent_lists = @sent_lists.page(params[:page])
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
    if params[:sent][:ids].present?
      sents = Sent.where(owner_id: params[:sent][:ids].split(','), owner_type: Order.name)
      label_size = sents.map{|s| s.cupboard.to_i + s.robe.to_i + s.door.to_i + s.part.to_i}.sum
      now = Time.now
      @sent_list = SentList.create(total: label_size, created_by: now.strftime('%Y-%m-%d %H:%M:%S'))
      # @sent_list.save!
      # @sent_list = @sent_list.reload  # 不需要重新加载 reload
      sents.each do |s|
        s.sent_list_id = @sent_list.id
        s.sent_at = now
        s.save!
        s.owner.sending!
        update_order_status(s.owner)
      end
      export_sent_list(@sent_list)
    else
      @sent_list = SentList.new(sent_list_params)
    end

    respond_to do |format|
      # if @sent_list.persisted?
      if @sent_list.save
        format.html { redirect_to @sent_list, notice: '发货清单创建成功！' }
        format.pdf do
          # 打印尺寸毫米（长宽）
          pdf = SentListPdf.new(sent_list)
          send_data pdf.render, filename: "发货清单#{sent_list.name}.pdf",
            type: "application/pdf",
            disposition: "inline"
        end
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

  # GET /sent_lists/1/download.xls
  # GET /sent_lists/1/download.pdf
  def download
    respond_to do |format|
      format.xls do
        send_file "#{Rails.root}/public/excels/sent_lists/" + @sent_list.name + ".xls", type: 'text/xls; charset=utf-8'
      end
      format.pdf do
        # 打印尺寸毫米（长宽）
        pdf = SentListPdf.new(@sent_list)
        send_data pdf.render, filename: "发货清单#{@sent_list.name}.pdf",
          type: "application/pdf",
          disposition: "inline"
      end
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

    # 下载报价单并转换为csv
    def to_csv(send_list)
      return [] if send_list.nil?
      # make excel using utf8 to open csv file
      # head = 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()
      # head = '\xEF\xBB\xBF'.split(' ').map{|a|a.hex.chr}.join()
      # head = ""
      CSV.generate do |csv|

        csv << ['序号', '地区', '收货人', '联系方式', '订单编号', '橱', '衣', '门', '配', '合计', '代收', '物流名称']

        index = 0
        send_list.sents.group_by{|s| [s.area, s.receiver, s.contact, s.logistics]}.each_pair do  |keys, values|
          sents = []
          sents << index += 1
          sents <<  keys[0]
          sents <<  keys[1]
          sents <<  keys[2]
          sents <<  values.first.owner.name
          sents <<  values.first.cupboard
          sents <<  values.first.robe
          sents <<  values.first.door
          sents <<  values.first.part
          sents <<  values.map{|sent| sent.cupboard + sent.robe + sent.door + sent.part }.sum
          sents <<  values.map(&:collection).sum
          sents <<  keys[3]
          csv << sents
          values.each_with_index do |v, i|
            next if i.zero?
            sents_group = ['', '', '', '']
            sents_group <<  v.owner.name
            sents_group <<  v.cupboard
            sents_group <<  v.robe
            sents_group <<  v.door
            sents_group <<  v.part
            csv << sents_group
          end
        end
      end#.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")
    end
end
