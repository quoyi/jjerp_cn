RuCaptcha.configure do
  # Color style, default: :colorful, allows: [:colorful, :black_white]
  # self.style = :colorful

  # Custom captcha code expire time if you need, default: 2 minutes
  # self.expires_in = 120

  # Override cache_store configuration just only [:null_store, :memory_store, :file_store]
  # 开发环境可能为 null_store 需要添加此配置
  self.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

  # Disable cache_store check
  # self.skip_cache_store_check = true

  # Chars length, default: 5, allows: [3 - 7]
  # self.length = 5

  # enable/disable Strikethrough.
  # self.strikethrough = true

  # enable/disable Outline style
  # self.outline = false
end
