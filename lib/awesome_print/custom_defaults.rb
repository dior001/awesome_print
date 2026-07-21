# frozen_string_literal: true

module AwesomePrint
  # Module-level configuration and console-integration helpers.
  #
  # +AwesomePrint.defaults+ holds a hash of options applied to every {Kernel#ai}
  # call, and +AwesomePrint.force_colors+ forces colorized output regardless of
  # whether the output is a TTY.
  class << self
    # @return [Hash, nil] default options merged into every +ai+ call.
    # @return [Boolean, nil] whether colorized output is forced.
    attr_accessor :defaults, :force_colors

    # Force (or unforce) colorized output, e.g. in a forked subprocess where
    # +TERM+ might be +dumb+.
    # @param value [Boolean] whether to force colors.
    #---------------------------------------------------------------------------
    def force_colors!(value = true)
      @force_colors = value
    end

    # @return [Boolean] true when running inside an IRB or Pry console.
    def console?
      boolean(defined?(IRB) || defined?(Pry))
    end

    # @return [Boolean] true when running inside a Rails console specifically.
    def rails_console?
      console? && boolean(defined?(Rails::Console) || ENV.fetch('RAILS_ENV', nil))
    end

    # Patches IRB so that evaluated values are rendered with Awesome Print.
    def usual_rb
      IRB::Irb.class_eval do
        def output_value(*_args)
          ap @context.last_value
        rescue NoMethodError
          puts "(Object doesn't support #ai)"
        end
      end
    end

    # Enable Awesome Print as IRB's result formatter (no-op unless IRB is loaded).
    def irb!
      return unless defined?(IRB)

      usual_rb
    end

    # Enable Awesome Print as Pry's print proc (no-op unless Pry is loaded).
    def pry!
      Pry.print = proc { |output, value| output.puts value.ai } if defined?(Pry)
    end

    private

    # Takes a value and returns true unless it is false or nil
    # This is an alternative to the less readable !!(value)
    # https://github.com/bbatsov/ruby-style-guide#no-bang-bang
    def boolean(value)
      value ? true : false
    end
  end
end
