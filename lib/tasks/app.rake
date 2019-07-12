# frozen_string_literal: true

namespace :app do
  # 'Overwrite figaro configuration.yml file'
  task :config do
    example = File.join("config", "application.example.yml")
    target = File.join("config", "application.yml")
    sh "rm -f #{target}" if File.file?(example)
    cp example, target, verbose: true
  end
end
