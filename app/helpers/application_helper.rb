module ApplicationHelper
  def toast_type_by(flash_type)
    case flash_type
    when 'notice'
      'info'
    when 'alert'
      'warning'
    when 'error'
      'error'
    else
      'success'
    end
  end

  # 提示标题
  def toast_title_by(flash_type)
    case flash_type
    when 'notice'
      '提示'
    when 'alert'
      '警告'
    when 'error'
      '错误'
    else
      '成功'
    end
  end
end
