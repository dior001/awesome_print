# frozen_string_literal: true

require_relative 'base_formatter'
require 'shellwords'

module AwesomePrint
  module Formatters
    # Formats a Dir, appending an 'ls -alF' style listing of its contents.
    class DirFormatter < BaseFormatter
      attr_reader :dir, :inspector, :options

      def initialize(dir, inspector)
        @dir = dir
        @inspector = inspector
        @options = inspector.options
      end

      def format
        ls = `ls -alF #{dir.path.shellescape}`
        colorize(ls.empty? ? dir.inspect : "#{dir.inspect}\n#{ls.chop}", :dir)
      end
    end
  end
end
