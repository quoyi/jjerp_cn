module OrdersHelper
  # 从CSV文件导入拆单信息（部件、配件）
  # file: 导入的文件
  # name: 子订单编号
  def import_order_units(file, name)
    if file.original_filename !~ /.csv$/
      _return = "文件格式不正确！"
    else
      # 这里的编码问题是个隐患
      table = CSV.read(file.path, {headers: true, encoding: 'GB18030:UTF-8'})
      headers = table.headers[0..15].map(&:strip)
      template = ["部件名称", "板材", "长", "宽", "厚", "数量", "裁切尺寸", "柜体名称", "订单号", "订货商", "终端信息", "封边", "纹理", "备注", "条码", "流水号"]
      index = 0
      _return = "文件导入错误！"
      if headers == template
        order = Order.find_by(name: name)
        if order
          # 开启事务
          ActiveRecord::Base.transaction do
            units = Unit.where(order_id: order.id).order("name ASC")
            # 其实这里可以不用提取出来（性能上一样，都是计算两次）
            last_units = units.last
            last_unit_index = last_units.present? ? (last_units.name.split(/-/).last.to_i + 1).to_s : '1'
            units.destroy_all
            # 删除已存在的拆单记录
            Unit.where(order_id: order.id).destroy_all
            table.each do |row|
              # next if row[8].blank? || row[8].strip != name
              # ply = row[1].split(/板/).last
              # ply = ply.gsub(/厚/, 'mm')
              unless MaterialCategory.all.map(&:name).include?(order.id)
                _return = "找不到板料"
              end
              unit = Unit.new(
                order_id: order.id,
                name: "ESR" + order.name + "-" + (index + 1).to_s,
                full_name: row[0],
                ply: order.id,
                length: row[2],
                width: row[3],
                number: row[5],
                price: Material.find_by(ply: order.id, texture: order.texture, color: order.color).try(:price).to_f,
                size: row[6],
                customer: row[10],
                edge: row[11],
                note: row[13]
              )
              # binding.pry
              unit.save!
              index += 1
            end
            if index > 0
              # 导入成功后的其他逻辑
              # order.separated!
              _return = "导入成功！本次导入 #{index} 条记录"
            else
              # 当导入的记录条数没有变化时，回滚事务（找回删除掉的拆单记录）!!注意:必须在回滚之前做处理!!
              _return = "所选文件中未找到订单号 #{name} 对应的记录！"
              raise ActiveRecord::Rollback
            end
          end
        else
          _return = "未找到编号为 #{name} 的订单，请检查订单号是否正确！"
        end
      else
        _return = "上传文件的表头错误！#{template}"
      end
    end
    return _return
  end


  # 修改子订单和总订单
  def update_order_and_indent(order)
    indent = order.indent
    # 获取上级子订单所有的 部件、配件、工艺，并计算总价
    # 部件 总价 = 面积 * 数量 * 单价
    total_units = order.units.map{|u| u.size.split(/[xX*]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum()
    total_parts = order.parts.map{|p| p.number * p.price}.sum()
    total_crafts = order.crafts.map{|c| c.number * c.price}.sum()
    indent.amount = order.price = total_units + total_parts + total_crafts
    order.save!
    indent.save!
  end
end
