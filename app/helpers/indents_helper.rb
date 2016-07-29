module IndentsHelper
  def update_indent_status(indent_or_indents, flag)
    if flag
      indent_or_indents.each do |indent|
        orders = indent.orders
        count_order = orders.size
        sum_order_status = 0
        orders.each do |order|
          sum_order_status += Order.statuses[order.status.to_sym]
        end
        # indent.status: 0,1,2,3,4
        # order.status: 0,1,2,3,4
        if sum_order_status >= count_order * 1
          indent.offered!
        elsif sum_order_status >= count_order * 2
          indent.producing!
        elsif sum_order_status >= count_order * 3
          indent.packaged!
        elsif sum_order_status >= count_order * 4
          indent.sent!
        else
          indent.offering!
        end
      end
    else
      orders = indent_or_indents.orders
      count_order = orders.size
      sum_order_status = 0
      orders.each do |order|
        sum_order_status += Order.statuses[order.status.to_sym]
      end
      # indent.status: 0,1,2,3,4
      # order.status: 0,1,2,3,4
      if sum_order_status >= count_order * 1
        indent_or_indents.offered!
      elsif sum_order_status >= count_order * 2
        indent_or_indents.producing!
      elsif sum_order_status >= count_order * 3
        indent_or_indents.packaged!
      elsif sum_order_status >= count_order * 4
        indent_or_indents.sent!
      else
        indent_or_indents.offering!
      end
    end
  end
  # def export_execl(indent)
  #   return nil if indent.nil?
  #   offers = indent.offers
  #   # 新建一个 indent.name + ".xls" 的 excel 文件，并添加一个 sheet
  #   wb = WriteExcel.new(indent.name + '.xls')
  #   ws = wb.add_worksheet
  #   # 语法 write(row, column, text)
  #   ws.write(0, 0, "总订单号")
  #   ws.write(0, 1, indent.name)
  #   ws.write(0, 2, "代理商")
  #   ws.write(0, 3, indent.agent.full_name)
  #   ws.write(0, 4, "终端客户")
  #   ws.write(0, 5, indent.customer)
  #   ws.write(0, 6, "总套数")
  #   ws.write(0, 7, indent.orders.map(&:number).sum())
  #   ws.write(1, 0, "下单时间")
  #   ws.write(1, 1, indent.verify_at)
  #   ws.write(1, 2, "发货时间")
  #   ws.write(1, 3, indent.require_at)
  #   ws.write(1, 4, "状态")
  #   ws.write(1, 5, indent.status_name)
  #   ws.write(1, 6, "金额￥")
  #   ws.write(1, 7, offers.map{|o| o.order.number * o.total}.sum())

  #   wb.close
  # end
end
