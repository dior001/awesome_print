# frozen_string_literal: true

# Copyright (c) 2010-2016 Michael Dvorkin and contributors
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module Kernel
  # Returns the awesome-printed representation of +self+ as a string.
  #
  # This is the core of Awesome Print: it is mixed into every object so you can
  # call +object.ai+ to get a colorized, indented string without printing it.
  #
  # @param options [Hash] formatting options merged over the defaults and any
  #   +~/.aprc+ overrides. Common keys include +:plain+ (disable color),
  #   +:indent+, +:index+, +:sort_keys+, +:limit+, +:html+ and +:raw+. See
  #   {AwesomePrint::Inspector#initialize} for the full list.
  # @return [String] the formatted representation (wrapped in a +<pre>+ block
  #   when +:html+ is true).
  def ai(options = {})
    ap = AwesomePrint::Inspector.new(options)
    awesome = ap.awesome self
    if options[:html]
      awesome = "<pre>#{awesome}</pre>"
      awesome = awesome.html_safe if defined? ActiveSupport
    end
    awesome
  end
  alias awesome_inspect ai

  # Awesome-prints +object+ to +$stdout+ and returns it, so +ap+ can be dropped
  # into a method chain. Outside of an IRB/Pry console the object is returned
  # (mirroring +Kernel#p+); inside a console +nil+ is returned to avoid the
  # value being echoed twice.
  #
  # @param object [Object] the object to print.
  # @param options [Hash] the same formatting options accepted by {#ai}.
  # @return [Object, nil] +object+ outside a console, otherwise +nil+.
  def ap(object, options = {})
    puts object.ai(options)
    object unless AwesomePrint.console?
  end
  alias awesome_print ap

  module_function :ap
end
