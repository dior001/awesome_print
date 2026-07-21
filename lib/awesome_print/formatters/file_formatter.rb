# frozen_string_literal: true

require_relative 'base_formatter'
require 'shellwords'

module AwesomePrint
  module Formatters
    # Formats a File, appending an 'ls -alF' style listing.
    class FileFormatter < BaseFormatter
      attr_reader :file, :inspector, :options

      def initialize(file, inspector)
        @file = file
        @inspector = inspector
        @options = inspector.options
      end

      def format
        ls = File.directory?(file) ? `ls -adlF #{file.path.shellescape}` : `ls -alF #{file.path.shellescape}`
        colorize(ls.empty? ? file.inspect : "#{file.inspect}\n#{ls.chop}", :file)
      end
    end
  end
end
