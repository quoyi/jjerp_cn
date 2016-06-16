class OrderPdf < Prawn::Document
  include Prawn::Measurements
  require 'prawn/table'
  def initialize(length, width, ids, order_id)
    super(:page_size => [mm2pt(length), mm2pt(width)], :margin => [2, 2])
    font "#{Rails.root}/app/assets/fonts/simfang.ttf", size: 5
    @order = Indent.find(order_id)
    @ids = ids
    @length = mm2pt(length) - 4

    order_units_parts
    # autoprint
    print
  end

  def order_number
    text "客户单号：#{@order.id}", :size => 10
    move_down(5)
  end

  def order_units_parts
    @ids.each_pair do |key, values|
      if key != "1"
        start_new_page
      end
      order_number
      move_down(5)
      table line_item_rows(values) do |row|
        row.width = @length
      end
    end
  end

  def line_item_rows(values)
    [['编码', '部件名称', '板材', '长', '宽', '厚', '数量', '颜色']] + get_order_units(values) + get_order_part(values)
  end

  def get_order_units(ids)
    order_units = []
    ids.each do |id|
      next unless id =~ /order_unit/
      id = id.gsub(/order_unit_/,'')
      order_units << Unit.find(id)
    end
    order_units.map do |order_unit|
      unless order_unit.is_printed
        order_unit.update_attributes(is_printed: true)
      end
      [order_unit.id, order_unit.name, order_unit.full_name, order_unit.length, order_unit.width, order_unit.ply_name, order_unit.number, order_unit.color_name]
    end
  end

  def get_order_part(ids)
    order_parts = []
    ids.each do |id|
      next unless id =~ /order_part/
      id = id.gsub(/order_part_/,'')
      order_parts << Part.find(id)
    end
    order_parts.map do |order_part|
      unless order_part.is_printed
        order_part.update_attributes(is_printed: true)
      end
      [order_part.id, '配件', order_part.part_category.name, '', '', '', order_part.number, '']
    end
  end

end