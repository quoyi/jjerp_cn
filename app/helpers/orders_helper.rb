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
        # 子订单的板料信息
        # order_material = MaterialCategory.find_by_id(order.color).try(:name) + 
        #                  MaterialCategory.find_by_id(order.texture).try(:name) + 
        #                  MaterialCategory.find_by_id(order.ply).try(:name)
        order_material = MaterialCategory.where("id in (#{order.color},#{order.texture}, #{order.ply})").order(oftype: :desc).map(&:name).join()
        return "未找到板料#{order_material}" unless Material.find_by(full_name: order_material)
        if order
          # 开启事务
          begin
            ActiveRecord::Base.transaction do
              units = Unit.where(order_id: order.id).order("name ASC")
              # 其实这里可以不用提取出来（性能上一样，都是计算两次）
              last_units = units.last
              last_unit_index = last_units.present? ? (last_units.name.split(/-/).last.to_i + 1).to_s : '1'
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
                #   _return = "未找到板料#{order_material}"
                # end
                unit = Unit.new(
                  order_id: order.id,
                  name: order.name + "-b-" + (index + 1).to_s,
                  full_name: row[0],
                  ply: order.id,
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
          rescue ActiveRecord::RecordInvalid => exception
            _return = "数据格式不正确，请检查！"
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
    order.reload
    indent = order.indent
    old_total = indent.amount
    # 获取上级子订单所有的 部件、配件、工艺，并计算总价
    # 部件 总价 = 面积 * 数量 * 单价
    total_units = order.units.map{|u| u.size.split(/[xX*×]/).map(&:to_i).inject(1){|result,item| result*=item}/(1000*1000).to_f * u.number * u.price}.sum()
    total_parts = order.parts.map{|p| p.number * p.price}.sum()
    total_crafts = order.crafts.map{|c| c.number * c.price}.sum()
    total_incomes = indent.incomes.map(&:money).sum
    new_total = indent.amount = order.price = total_units + total_parts + total_crafts
    indent.arrear = indent.amount - total_incomes
    indent.total_history += (new_total - old_total)
    indent.total_arrear += (new_total - old_total)
    order.save!
    indent.save!
  end
end
