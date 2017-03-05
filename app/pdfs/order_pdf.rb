class OrderPdf < Prawn::Document
  include Prawn::Measurements
  require 'prawn/table'
  require 'barby/barcode/code_39'
  require 'barby/outputter/png_outputter'

  def initialize(length, width, ids, order)
    super(page_size: [mm2pt(length), mm2pt(width)], margin: [2, 2])
    font "#{Rails.root}/app/assets/fonts/msyh.ttf", size: 12
    # @length = mm2pt(length) - 4  # 可能需要转换
    # 生成条形码
    tmp_code = order.name.split('-')
    barcode = Barby::Code39.new(tmp_code[1] + '-' + tmp_code[2])
    File.open("#{Rails.root}/public/images/#{order.name}.png", 'wb') { |f| f.write barcode.to_png }
    # 调用 打印 方法
    ids.downto(1).each_with_index do |_id, index|
      start_new_page unless index.zero?
      text '高端定制橱柜衣柜', align: :center, size: 18, styles: :bold
      pad_top(1) { text "编号: #{order.name}" }
      pad_top(1) { text "展厅: #{order.indent.agent.full_name[0, 16]}" }
      pad_top(1) { text '终端: ' }
      pad_top(1) { text_box order.indent.customer[0, 32].to_s, at: [30, cursor + 13] }
      text ' '
      pad_top(1) { text "产品: #{order.order_category.try(:name)[0, 16]}" }
      pad_top(1) { text '备注: ' }
      # 字体高度12 ，上下內补1 =>  12 + 1 + 1 = 14
      pad_top(1) { text_box order.note[0, 32].to_s, at: [30, cursor + 13] }
      text ' '
      text "货  到: #{order.delivery_address[0, 7]}", size: 16, styles: :bold
      # 二维码
      # image "#{Rails.root}/app/assets/images/d2code.png", at: [2, cursor], width: 38, height: 38
      # 条形码
      image "#{Rails.root}/public/images/#{order.name}.png", width: 120, height: 20, position: :left, vposition: :bottom
      text "共 #{ids} 件 第 #{ids} - #{index + 1} 件", size: 9, align: :right, valign: :bottom
    end
    # autoprint  # 自动打印
    print # 手动调用 打印 方法
  end
end
