# frozen_string_literal: true

# require 'qiniu'
# Qiniu.establish_connection! access_key: 'ttBdVzznFEazytbwWBqoHUwRKCFPo3osakSGg5Nv',
#                             secret_key: 'ExLSnZ1Z-KOGV5Qt_4EAw0gt45fkcBojBNX0jzw2'

# # 要上传的空间
# bucket = 'jjerp-cn'
# # 上传到七牛后保存的文件名
# key = 'my-ruby-logo.png'
# # 构建上传策略，上传策略的更多参数请参照 http://developer.qiniu.com/article/developer/security/put-policy.html
# put_policy = Qiniu::Auth::PutPolicy.new(
#   bucket, # 存储空间
#   key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
#   3600    # token 过期时间，默认为 3600 秒，即 1 小时
# )
# # 生成上传 Token
# uptoken = Qiniu::Auth.generate_uptoken(put_policy)
# # 要上传文件的本地路径
# filePath = './ruby-logo.png'
# # 调用 upload_with_token_2 方法上传
# code, result, response_headers = Qiniu::Storage.upload_with_token_2(
#   uptoken,
#   filePath,
#   key,
#   nil, # 可以接受一个 Hash 作为自定义变量，请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#xvar
#   bucket: bucket
# )
# # 打印上传返回的信息
# puts code
# puts result
