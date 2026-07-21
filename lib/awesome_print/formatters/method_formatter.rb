# frozen_string_literal: true

require_relative 'base_formatter'

module AwesomePrint
  module Formatters
    # Formats a Method or UnboundMethod as owner#name(args).
    class MethodFormatter < BaseFormatter
      attr_reader :method, :inspector, :options

      def initialize(method, inspector)
        @method = method
        @inspector = inspector
        @options = inspector.options
      end

      def format
        name, args, owner = method_tuple(method)

        "#{colorize(owner, :class)}##{colorize(name, :method)}#{colorize(args, :args)}"
      end
    end
  end
end
