namespace :util do
  desc '清理 public/excels/**/*.xls 临时文件'
  task :clear do
    # excels = Dir.glob(Rails.root.join('public/excels/**/*.xls'))
    # File.delete(*excels)
    File.open(Rails.root.join('log/crontab.log'), 'a+') do |logger|
      Dir.glob(Rails.root.join('public/excels/**/*.xls')).each do |file|
        logger.write("#{Time.current.strftime('%Y-%m-%d %H:%M:%S')} #{File.basename(file)}")
        File.delete(file)
      end
    end
  end

  desc '生成项目配置文件 application.yml'
  task :config do
    template = Rails.root.join('config/application.example.yml')
    target = Rails.root.join('config/application.yml')
    cp template, target, verbose: true unless File.exist?(target)
  end
end
