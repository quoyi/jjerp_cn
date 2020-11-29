namespace :util do
  desc '清除 public/excels/**/*.xls 临时文件'
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
end
