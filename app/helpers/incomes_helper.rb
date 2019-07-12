module IncomesHelper
  require 'find'
  # 新建 /public/excels/incomes/#{timestamp}.xls 文件，列出所有 incomes
  def create_incomes(timestamp, incomes)
    directory = "#{Rails.root}/public/excels/incomes"
    # 删除 /public/excels/incomes/ 目录下前一天的文件
    Dir.foreach(directory) do |filename|
      if (filename != '.') && (filename != '..')
        File.delete(directory + '/' + filename) if filename.gsub('.xls', '').to_i < Date.today.strftime('%Y%m%d%H%M%S%L').to_i
      end
    end

    wb = WriteExcel.new("#{Rails.root}/public/excels/incomes/" + timestamp + '.xls')
    ws = wb.add_worksheet
    ws.set_column('A:G', 25) # 设置列宽
    ws.set_column('C:C', 40)

    # 第一行
    title_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 28) # 水平居中、垂直居中、加粗、字号28
    info_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 0, size: 16, border: 1)
    thead_format = wb.add_format(align: 'center', valign: 'vcenter', bold: 1, size: 16, bg_color: 'gray', border: 1)
    ws.merge_range('A1:G1', '收入清单', title_format)
    ws.set_row(0, 34) # 设置行高

    ws.set_row(1, 23)
    ws.write_row('A2', %w[编号 来源 收入卡号 收入时间 收入金额 经手人 备注], thead_format)

    row_num = 3
    incomes.each_with_index do |income, index|
      ws.write_row('A' + row_num.to_s, [index + 1, income.reason, income.bank.bank_card, income.income_at.strftime('%Y-%m-%d'),
                                        income.money, income.username, income.note], info_format)
      ws.set_row(row_num - 1, 20)
      row_num += 1
    end

    wb.close
  end
end
