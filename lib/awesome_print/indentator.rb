# frozen_string_literal: true

module AwesomePrint
  # Tracks the current indentation width while formatting nested structures.
  # Each level is +shift_width+ spaces; {#indent} widens the indentation for the
  # duration of a block and restores it afterwards.
  class Indentator
    attr_reader :shift_width, :indentation

    # @param indentation [Integer] the per-level indentation width, in spaces.
    def initialize(indentation)
      @indentation = indentation
      @shift_width = indentation.freeze
    end

    # Increase the indentation by one level for the duration of the block.
    # @yield the block to run while indented.
    def indent
      @indentation += shift_width
      yield
    ensure
      @indentation -= shift_width
    end
  end
end
