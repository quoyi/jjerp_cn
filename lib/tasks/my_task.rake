namespace :my_task do
  desc "清除所有 /public/excels/**.xls"
  task :clear_excels do
    require 'find'
    Find.find("/home/zw/work/jjerp.cn/public/excels/").each do |file|
      if File.extname(file) == ".xls"
        # 追加模式打开 log 文件
        File.open("/home/zw/work/jjerp.cn/log/crontab.log", "a") do |f|
          f.puts Time.now.strftime("%Y-%m-%d %H:%M:%S") + " 删除文件： " + File.basename(file) + "\n"
        end
        File.delete(file)
      end
    end
  end

  desc "清除所有无用文件"
  task :clear do
    puts "测试清除所有无用文件"
  end

end
