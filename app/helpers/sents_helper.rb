module SentsHelper
  # 导出发货清单
  # 额外例子： OrdersHelper.export_orders()
  def export_sent_list(sent_list)
    wb = WriteExcel.new("#{Rails.root}/public/excels/sent_lists/" + sent_list.name + ".xls")
    ws = wb.add_worksheet
    # 标题样式：水平居中、垂直居中、加粗、字号20
    title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size:20)
    # 表标题样式：水平居左、垂直居中、不加粗、字号16
    table_title_format = wb.add_format(align: 'left', valign: 'vcenter', bold: 0, size: 16)
    # 表头样式：水平居左、垂直居中、不加粗、字号16
    table_header_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, bg_color: 'gray')
    # 正文样式：水平居中、垂直居中、不加粗、字号16
    info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, border: 1)
    # 表根样式：水平居中、垂直居中、不加粗、字号16
    table_footer_format = wb.add_format(align: 'right', valign: 'vcenter', bold: 0, size: 16)

    # 设置列宽
    ws.set_column("A:E", 18)
    ws.set_column("K:M", 18)

    ws.merge_range("A1:M1", '伊思尔制造中心 ——— 发货清单', title_format)
    ws.set_row(0, 34) # 设置行高

    ws.merge_range("A2:M2", sent_list.created_by.split(" ")[0] + "发货清单", table_title_format)
    ws.set_row(1, 28) # 设置行高

    header = ["序号", "地区", "收货人", "联系方式", "订单编号", "橱", "衣", "门", "配", "合计", "代收", "物流名称", "货号"]
    ws.write_row("A3", header, table_header_format)
    ws.set_row(2, 28)

    row_num = 4
    count = 0
    # 写入数据
    sent_list.sents.each_with_index do |sent, index|
      sent_count = sent.cupboard + sent.robe + sent.door + sent.part
      sent_info = [(index + 1).to_s, sent.area, sent.receiver, sent.contact, sent.owner.name, sent.cupboard, sent.robe,
                   sent.door, sent.part, sent_count, sent.collection, sent.logistics, "" ]
      ws.set_row(row_num - 1, 18)
      ws.write_row("A" + row_num.to_s, sent_info, info_format)
      count += sent_count
      row_num += 1
    end
    # ws.set_border("A3:M" + row_num.to_s, 1)

    ws.merge_range("A7:M7", "[打单时间：" + Time.new.strftime("%Y-%m-%d %H:%M:%S") + "] [数量合计：" + 
                   count.to_s + "件]", table_footer_format)
    ws.set_row(6, 28) # 设置行高

    wb.close
  end
end
