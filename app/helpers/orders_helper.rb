module OrdersHelper
  # 从CSV文件导入拆单信息（部件、配件）
  # file: 导入的文件
  # name: 子订单编号
  def import_order_units(file, name)
    if file.original_filename !~ /.csv$/
      msg = '文件格式不正确！'
    else
      # 这里的编码问题是个隐患
      table = CSV.read(file.path, headers: true, encoding: 'GB18030:UTF-8')
      headers = table.headers[0..15].map(&:strip)
      template = %w[部件名称 板材 长 宽 厚 数量 裁切尺寸 柜体名称 订单号 订货商 终端信息 封边 纹理 备注 条码 流水号]
      index = 0
      msg = '文件导入错误！'
      if headers == template
        order = Order.find_by(name: name)
        # 子订单的板料信息
        # order_material = MaterialCategory.find_by_id(order.color).try(:name) +
        #                  MaterialCategory.find_by_id(order.texture).try(:name) +
        #                  MaterialCategory.find_by_id(order.ply).try(:name)
        order_material = MaterialCategory.where("id in (#{order.color},#{order.texture}, #{order.ply})").order(oftype: :desc).map(&:name).join
        return "未找到板料#{order_material}" unless Material.find_by(full_name: order_material)

        if order
          # 开启事务
          begin
            ActiveRecord::Base.transaction do
              units = Unit.where(order_id: order.id).order('name ASC')
              # 其实这里可以不用提取出来（性能上一样，都是计算两次）
              # last_units = units.last
              # last_unit_index = last_units.present? ? (last_units.name.split(/-/).last.to_i + 1).to_s : '1'
              units.destroy_all
              # 删除已存在的拆单记录
              # Unit.where(order_id: order.id).destroy_all
              # 部件（板料）价格，避免查询多次
              unit_price = Material.find_by(ply: order.ply, texture: order.texture, color: order.color).try(:price).to_f
              table.each do |row|
                next if row[0].blank?

                # next if row[8].blank? || row[8].strip != name
                # ply = row[1].split(/板/).last
                # ply = ply.gsub(/厚/, 'mm')
                # unless Material.all.map(&:full_name).include?(order_material)
                #   msg = "未找到板料#{order_material}"
                # end
                unit = Unit.new(
                  order_id: order.id,
                  # name: order.name + "-B-" + (index + 1).to_s,
                  full_name: row[0],
                  ply: order.ply,
                  texture: order.texture,
                  color: order.color,
                  length: row[2],
                  width: row[3],
                  number: row[5],
                  price: unit_price,
                  size: row[6],
                  customer: row[10],
                  edge: row[11],
                  note: row[13]
                )
                unit.save!
                index += 1
              end
              if index.positive?
                # 导入成功后的其他逻辑
                # order.separated!
                msg = "导入成功！本次导入 #{index} 条记录"
              else
                # 当导入的记录条数没有变化时，回滚事务（找回删除掉的拆单记录）!!注意:必须在回滚之前做处理!!
                msg = "所选文件中未找到订单号 #{name} 对应的记录！"
                raise ActiveRecord::Rollback
              end
            end
          rescue ActiveRecord::RecordInvalid => _e
            msg = '数据格式不正确，请检查！'
          end
        else
          msg = "未找到编号为 #{name} 的订单，请检查订单号是否正确！"
        end
      else
        msg = "上传文件的表头错误！#{template}"
      end
    end
    msg
  end

  def export_offers(indent)
    filename = "#{indent.name}.xls"
    offers = indent.offers
    wb = WriteExcel.new(Rails.root.join("public/excels/offers/#{filename}"))
    ws = wb.add_worksheet
    ws.set_column('A:H', 25) # 设置列宽
    ws.set_column('C:C', 40)

    # 第一行
    title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 28) # 水平居中、垂直居中、加粗、字号28
    info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 16, border: 1)
    thead_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16, bg_color: 'gray', border: 1)
    ws.merge_range('A1:H1', '报价单', title_format)
    ws.set_row(0, 34) # 设置行高

    # 空行(合并单元格、正文样式)
    # ws.write_blank(1,0)
    # ws.merge_range("A2:H2", '', info_format)
    ws.set_row(1, 23)
    ws.write_row('A2', ['总订单号', indent.name, '代理商', indent.agent.full_name,
                        '终端客户', indent.customer, '套数', indent.orders.map(&:number).sum], thead_format)
    ws.set_row(2, 23)
    ws.write_row('A3', ['下单时间', indent.verify_at, '发货时间', indent.require_at, '状态', indent.status_name,
                        '金额￥', offers.map { |o| o.order.number * o.total }.sum.round], thead_format)
    ws.set_row(3, 23)
    ws.write_row('A4', ['序号', '类型', '名称', '单价￥', '单位', '数量', '备注', '总价￥'], thead_format)

    row_num = 5
    offers.group_by(&:order_id).each_pair do |_order_id, ofs|
      ofs.each_with_index do |offer, index|
        ws.write_row("A#{row_num}", [index + 1, offer.item_type_name, offer.item_name, offer.price.round(2),
                                     offer.uom, offer.number, offer.note, offer.total.round], info_format)
        ws.set_row(row_num - 1, 20)
        row_num += 1
      end
      # 第一组报价单对应的订单信息
      order = ofs.first.order
      order_total = order.offers.map { |o| o.price * o.number }.sum.round
      orders_total = order_total * order.number
      ws.write_row("A#{row_num}", ['子订单号', order.name, '单套合计￥', order_total, '备注', order.note,
                                   '项目合计￥', orders_total], info_format)
      ws.set_row(row_num - 1, 20)
      row_num += 1
      ws.merge_range("A#{row_num}:H#{row_num}", '', info_format)
      ws.set_row(row_num - 1, 20)
      row_num += 1
    end
    wb.close
  end

  # 导出Excel格式 orders
  def export_orders(filename, orders, start_at, end_at)
    # 全局变量，当前行数
    row_num = '5'
    indents = orders.group(:indent_id).map(&:indent)
    total = indents.map(&:amount).sum
    wb = WriteExcel.new(Rails.root.join("public/excels/orders/#{filename}"))
    ws = wb.add_worksheet
    ws.set_column('A:H', 28)

    # 第一行
    title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 28) # 水平居中、垂直居中、加粗、字号28
    info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16)
    ws.merge_range('A1:H1', '对账单', title_format) # 合并单元格，写入数据，修改样式为 title_format
    ws.set_row(0, 34)

    # 空一行
    ws.write_blank(1, 0)
    ws.merge_range('A2:H2', '', info_format)

    # 第3行：公共信息

    ws.write('A3', '起止时间：', info_format)
    ws.write('B3', "#{start_at} 到 #{end_at}", info_format)
    ws.write('C3', '总订单数：', info_format)
    ws.write('D3', indents.count, info_format)
    ws.write('E3', '子订单数：', info_format)
    ws.write('F3', orders.count, info_format)
    ws.write('G3', '总金额：', info_format)
    ws.write('H3', total, info_format)
    ws.set_row(2, 28)

    # 空一行
    ws.write_blank(3, 0)
    ws.merge_range('A4:H4', '', info_format)

    # 第5行：订单信息
    myorange = wb.set_custom_color(12, 255, 201, 0)
    myyellow = wb.set_custom_color(13, 255, 255, 153)
    myblue = wb.set_custom_color(14, 0, 204, 255)
    mybluewhite = wb.set_custom_color(15, 204, 255, 255)
    indents.each_with_index do |indent, ii|
      indent_format = if ii.even?
                        wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16, bg_color: myorange, border: 1)
                      else
                        wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16, bg_color: myblue, border: 1)
                      end
      # 总订单信息一
      ws.set_row(row_num.to_i - 1, 28) # 设置第5行行高
      ws.write("A#{row_num}", '总订单号', indent_format)
      ws.write("B#{row_num}", indent.name, indent_format)
      ws.write("C#{row_num}", '经销商', indent_format)
      ws.write("D#{row_num}", indent.agent.full_name, indent_format)
      ws.write("E#{row_num}", '终端客户', indent_format)
      ws.write("F#{row_num}", indent.customer, indent_format)
      ws.write("G#{row_num}", '套数', indent_format)
      ws.write("H#{row_num}", indent.orders.count, indent_format)
      ws.set_row(row_num.to_i, 28) # 设置第6行行高
      row_num = (row_num.to_i + 1).to_s # 行数自加
      # 总订单信息二
      ws.write("A#{row_num}", '下单时间', indent_format)
      ws.write("B#{row_num}", indent.verify_at, indent_format)
      ws.write("C#{row_num}", '发货时间', indent_format)
      ws.write("D#{row_num}", indent.require_at, indent_format)
      ws.write("E#{row_num}", '状态', indent_format)
      ws.write("F#{row_num}", indent.status_name, indent_format)
      ws.write("G#{row_num}", '金额￥', indent_format)
      ws.write("H#{row_num}", indent.amount, indent_format)

      order_title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 12, bg_color: myyellow, border: 1)
      order_info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 12, bg_color: 'gray', border: 1)
      order_format = if ii.even?
                       wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, bg_color: myyellow, border: 1)
                     else
                       wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 12, bg_color: mybluewhite, border: 1)
                     end
      ws.set_row(row_num.to_i, 20) # 设置第7行行高
      row_num = (row_num.to_i + 1).to_s
      # 子订单信息表头
      ws.write("A#{row_num}", '序号', order_title_format)
      ws.write("B#{row_num}", '类型', order_title_format)
      ws.write("C#{row_num}", '名称', order_title_format)
      ws.write("D#{row_num}", '单价￥', order_title_format)
      ws.write("E#{row_num}", '单位', order_title_format)
      ws.write("F#{row_num}", '数量', order_title_format)
      ws.write("G#{row_num}", '备注', order_title_format)
      ws.write("H#{row_num}", '总价￥', order_title_format)
      # 子订单信息
      indent.orders.each_with_index do |order, _oi|
        # 子订单信息一
        ws.set_row(row_num.to_i, 20)
        row_num = (row_num.to_i + 1).to_s
        ws.write("A#{row_num}", '子订单号', order_info_format)
        ws.write("B#{row_num}", order.name, order_info_format)
        ws.write("C#{row_num}", '订单类型', order_info_format)
        ws.write("D#{row_num}", order.order_category.name, order_info_format)
        ws.write("E#{row_num}", '备注', order_info_format)
        ws.write("F#{row_num}", order.note, order_info_format)
        ws.write("G#{row_num}", '项目合计￥', order_info_format)
        ws.write("H#{row_num}", order.price * order.number, order_info_format)

        order.offers.each_with_index do |offer, ooi|
          ws.set_row(row_num.to_i, 20)
          row_num = (row_num.to_i + 1).to_s
          ws.write("A#{row_num}", ooi + 1, order_format)
          ws.write("B#{row_num}", offer.item_type_name, order_format)
          ws.write("C#{row_num}", offer.item_name, order_format)
          ws.write("D#{row_num}", offer.price, order_format)
          ws.write("E#{row_num}", offer.uom, order_format)
          ws.write("F#{row_num}", offer.number, order_format)
          ws.write("G#{row_num}", offer.note, order_format)
          ws.write("H#{row_num}", offer.total, order_format)
        end
      end
      ws.set_row(row_num.to_i, 20)
      row_num = (row_num.to_i + 1).to_s
      ws.merge_range("A#{row_num}:H#{row_num}", '', info_format) # 空一行

      row_num = (row_num.to_i + 1).to_s
    end
    wb.close
  end

  # 修改子订单和总订单
  # def update_order_and_indent(order)
  #   indent = order.indent
  #   indent_sum = 0
  #   o = order
  #   # indent.orders.each do |o|
  #     sum_units = 0
  #     # 自定义报价不计算尺寸
  #     group_units = o.units.group_by{|u| u.is_custom}
  #     sum_units += group_units[true].map{|u| u.number * u.price}.sum() if group_units[true]
  #     sum_units += group_units[false].map{|u| u.size.split(/[xX*×]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum() if group_units[false]
  #     sum_parts = o.parts.map{|p| p.number * p.price}.sum()
  #     sum_crafts = o.crafts.map{|c| c.number * c.price}.sum()
  #     o.price = sum_units + sum_parts + sum_crafts  # 子订单金额 = 子订单部件合计 + 子订单配件合计 + 子订单工艺费合计
  #     # indent_sum += o.price
  #     o.save!
  #   # end
  #   #
  #   # indent_sum = indent.orders.pluck(:price).sum

  #   # arrear_sum = indent.incomes.map(&:money).sum.to_f
  #   # indent.amount = indent_sum  # 总订单金额 = 所有子订单金额合计
  #   # # 欠款 = 金额 - 收入
  #   # indent.arrear = indent_sum - arrear_sum
  #   # indent.save!

  #   # total_incomes = indent.incomes.map(&:money).sum
  #   # new_total = indent.amount = order.price = total_units + total_parts + total_crafts
  #   # indent.arrear = indent.amount - total_incomes
  #   # indent.total_history += (new_total - old_total)
  #   # indent.total_arrear += (new_total - old_total)
  # end

  # 修改子订单、总订单状态
  def update_order_status(order)
    indent = order.indent
    offers = order.reload.offers
    status = Order.statuses[order.status]
    order.offered! if status.zero? && !offers.empty?
    order.offering! if status == 1 && offers.empty?

    # 所有子订单中，最小状态值作为总订单的状态
    min_status = indent.orders.map { |o| Order.statuses[o.status] }.min
    max_status = indent.orders.map { |o| Order.statuses[o.status] }.max
    indent.update!(status: min_status, max_status: max_status)
  end
end
