Webpacker::Compiler.class_eval do
  def compile
    return true unless stale?

    run_webpack.tap { record_compilation_digest }
  end
end
