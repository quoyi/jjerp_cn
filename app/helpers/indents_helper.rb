module IndentsHelper
  # def export_execl(indent)
  #   return nil if indent.nil?
  #   offers = indent.offers
  #   # 新建一个 indent.name + ".xls" 的 excel 文件，并添加一个 sheet
  #   wb = WriteExcel.new(indent.name + '.xls')
  #   ws = wb.add_worksheet
  #   # 语法 write(row, column, text)
  #   ws.write(0, 0, "总订单号")
  #   ws.write(0, 1, indent.name)
  #   ws.write(0, 2, "经销商")
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
