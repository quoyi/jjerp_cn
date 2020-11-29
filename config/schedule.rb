# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# 定时任务 log 输出路径
set :output, "/home/zw/work/jjerp.cn/log/crontab.log"

# 定时任务(每天晚上12点删除 public/excels/* )
every :day, at: '12:00 pm' do
  # 执行 自定义 task 清除 .xls 文件
  rake "util:clear"
end
