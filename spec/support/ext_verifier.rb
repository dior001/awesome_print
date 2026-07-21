# frozen_string_literal: true

module ExtVerifier
  def require_dependencies!(dependencies)
    dependencies.each do |dependency|
      require dependency
    rescue LoadError
      # Optional integration gem is not installed; its specs will skip.
    end
  end
  module_function :require_dependencies!

  def has_rails?
    defined?(Rails)
  end
  module_function :has_rails?

  def has_mongoid?
    defined?(Mongoid)
  end
  module_function :has_mongoid?

  def has_sequel?
    defined?(Sequel)
  end
  module_function :has_sequel?
end

RSpec.configure do |config|
  config.include(ExtVerifier)
  config.extend(ExtVerifier)
end
