# frozen_string_literal: true

require_relative 'base_formatter'

module AwesomePrint
  module Formatters
    # Formats a Struct as sorted member = value pairs.
    class StructFormatter < BaseFormatter
      attr_reader :struct, :variables, :inspector, :options

      def initialize(struct, inspector)
        @struct = struct
        @variables = struct.members
        @inspector = inspector
        @options = inspector.options
      end

      def format
        # Struct members are bare symbols (`:name`), unlike an object's
        # `@`-prefixed instance variables, so they are simply rendered as
        # `member = value` pairs sorted by member name.
        data = struct.members.sort.map do |member|
          declaration = member.to_s
          key = left_aligned do
            align(declaration, declaration.size)
          end

          indented do
            key + colorize(' = ', :hash) + inspector.awesome(struct.send(member))
          end
        end

        if options[:multiline]
          "#<#{awesome_instance}\n#{data.join(",\n")}\n#{outdent}>"
        else
          "#<#{awesome_instance} #{data.join(', ')}>"
        end
      end

      private

      def awesome_instance
        Kernel.format("#{struct.class.superclass}:#{struct.class}:0x%08x", struct.__id__ * 2)
      end

      def left_aligned
        current = options[:indent]
        options[:indent] = 0
        yield
      ensure
        options[:indent] = current
      end
    end
  end
end
