module IndentsHelper
  # def update_indent_status(indent)
  #   orders = indent.orders
  #   count_order = orders.size
  #   sum_order_status = 0
  #   orders.each do |order|
  #     sum_order_status += Order.statuses[order.status.to_sym]
  #   end
  #   # indent.status: 0,1,2,3,4
  #   # order.status: 0,1,2,3,4
  #   if sum_order_status >= count_order * 1
  #     indent.offered!
  #   elsif sum_order_status >= count_order * 2
  #     indent.producing!
  #   elsif sum_order_status >= count_order * 3
  #     indent.packaged!
  #   elsif sum_order_status >= count_order * 4
  #     indent.sent!
  #   else
  #     indent.offering!
  #   end
  # end
  
  # 导出 配件清单
  def export_part_list(result)
    wb = WriteExcel.new("#{Rails.root}/public/excels/parts/" + result["file_name"] + ".xls")
    ws = wb.add_worksheet
    # 标题样式：水平居中、垂直居中、加粗、字号20
    title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size:20, border: 1)
    # 表标题样式：水平居左、垂直居中、不加粗、字号16
    table_title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16, bg_color: 'gray', border: 1)
    # 表头样式：水平居左、垂直居中、不加粗、字号16
    table_header_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, border: 1)
    # 正文样式：水平居中、垂直居中、不加粗、字号16
    info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, border: 1)
    # 表根样式：水平居中、垂直居中、不加粗、字号16
    table_footer_format = wb.add_format(align: 'right', valign: 'vcenter', bold: 0, size: 16)

    # 设置列宽
    ws.set_column("A:F", 18)

    ws.merge_range("A1:F1", '伊思尔生产管理 ——— 配件清单', title_format)
    ws.set_row(0, 34) # 设置行高

    indent_num = 1
    result.each_pair do |key, value|
      next if key == "file_name"
      num_cupboard = value["cupboard"].length
      num_others = value["others"].length
      # 必须存在配件，才显示总订单信息
      if num_cupboard > 0 || num_others > 0
        indent_num += 1

        ws.write_row("A" + indent_num.to_s, ["总订单号", value["indent"].name, 
                                                   "代理商", value["indent"].agent.try(:full_name), 
                                                   "终端客户", value["indent"].customer],
                                                   table_title_format)
        ws.set_row(indent_num - 1, 28) # 设置行高

        if num_cupboard > 0
          indent_num += 1
          ws.merge_range("A" + indent_num.to_s + ":F" + indent_num.to_s, "橱柜配件清单#{value["cupboard_orders_name"].join("，")}", table_title_format)
          ws.set_row(indent_num - 1 , 28) # 设置行高
          indent_num += 1

          ws.merge_range("E" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
          ws.write_row("A" + indent_num.to_s, ["名称", "规格", "品牌", "数量", "备注"], table_header_format)
          value["cupboard"].each_value do |cupboards|
            indent_num += 1
            ws.merge_range("E" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
            ws.write_row("A" + indent_num.to_s, [cupboards.first.part_category.try(:name), cupboards.first.uom, 
                                                 cupboards.first.brand, cupboards.map(&:number).sum(), 
                                                 cupboards.map(&:note).join(' ')], info_format)
          end
          indent_num += 1
          ws.merge_range("A" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
        end

        if num_others > 0
          indent_num += 1
          ws.merge_range("A" + indent_num.to_s + ":F" + indent_num.to_s, "衣柜配件清单#{value["other_orders_name"].join("，")}", table_title_format)
          ws.set_row(indent_num - 1 , 28) # 设置行高
          indent_num += 1

          ws.merge_range("E" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
          ws.write_row("A" + indent_num.to_s, ["名称", "规格", "品牌", "数量", "备注"], table_header_format)
          value["others"].each_value do |others|
            indent_num += 1
            ws.merge_range("E" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
            ws.write_row("A" + indent_num.to_s,[others.first.part_category.try(:name), others.first.uom,
                                                others.first.brand, others.map(&:number).sum(),
                                                others.first.note], info_format)
          end
          indent_num += 1
          ws.merge_range("A" + indent_num.to_s + ":F" + indent_num.to_s, "", info_format)
        end
      end
    end

    wb.close
  end
end
