# frozen_string_literal: true

# Copyright (c) 2010-2016 Michael Dvorkin and contributors
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module AwesomePrint
  # Mixed into Ruby's +Logger+ (and, by inheritance, +ActiveSupport::Logger+)
  # to add an +ap+ method that logs the awesome-printed form of an object.
  module Logger
    # Log the awesome-printed representation of +object+.
    #
    # @param object [Object] the object to log.
    # @param level [Symbol, nil] the log level to use; defaults to
    #   +AwesomePrint.defaults[:log_level]+ or +:debug+.
    #------------------------------------------------------------------------------
    def ap(object, level = nil)
      level ||= AwesomePrint.defaults[:log_level] if AwesomePrint.defaults
      level ||= :debug
      send level, object.ai
    end
  end
end

# ActiveSupport::Logger (Rails) subclasses ::Logger, so this single include also
# covers Rails loggers. ActiveSupport::BufferedLogger was removed years ago.
Logger.include AwesomePrint::Logger
