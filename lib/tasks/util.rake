namespace :util do
  desc '清除所有 /public/excels/**.xls'
  task :clear do
    require 'find'
    Find.find(Rails.root.join('public/excels/')).each do |file|
      next unless File.extname(file) == '.xls'

      # 追加模式打开 log 文件

      File.open(Rails.root.join('log/crontab.log'), 'a+') do |f|
        f.write("#{Time.current.strftime('%Y-%m-%d %H:%M:%S')} #{File.basename(file)}")
      end
      File.delete(file)
    end
  end
end
