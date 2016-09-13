class SentListPdf < Prawn::Document
  # 转换像素需要引入
  include Prawn::Measurements
  require 'prawn/table'

  def initialize(sent_list)
    # A4 尺寸 210 * 297
    super(page_size: "A4", margin: [5, 5], page_layout: :landscape)
    font "#{Rails.root}/app/assets/fonts/songti.ttf", size: 12
    @sent_list = sent_list
    print_content
    # autoprint # 自动打印
    print
  end


  def print_content
    sents = @sent_list.sents
    text @sent_list.name + " 发货清单", align: :left
    tbody = [["序号", "地区", "收货人", "联系方式", "订单编号", "橱", "衣", "门", "配", "合计", "代收", "物流名称"]]
    @sent_list.sents.each_with_index do |sent, index|
      sent_total = sent.cupboard + sent.robe + sent.door + sent.part
      tbody += [[(index + 1).to_s, sent.area, sent.receiver, sent.contact, sent.owner.name, sent.cupboard, sent.robe, sent.door, sent.part, sent_total, sent.collection, sent.logistics]]
    end
    # 打印表格
    table tbody do |row|
      row.width = mm2pt(297) - 10
    end
    text "发货时间：["+ @sent_list.created_by.to_s + "][数量合计：" + @sent_list.sents.map{|sent| sent.cupboard + sent.robe + sent.door + sent.part}.flatten.sum.to_s + "]件", align: :right
  end
end