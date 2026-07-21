# frozen_string_literal: true

autoload :CGI, 'cgi'

module AwesomePrint
  # Mixin providing {#colorize}, shared by the formatter and every plugin.
  # It applies the configured ANSI color (or HTML markup) for a given semantic
  # +type+ while honoring the +:plain+, +:html+ and color options, and stays
  # compatible with gems (such as +colorize+) that redefine +String+ color
  # methods.
  module Colorize
    # Apply the color configured for +type+ to +str+ (HTML-escaping first when
    # the +:html+ option is set).
    #
    # @param str [String] the text to colorize.
    # @param type [Symbol] the semantic color key (e.g. +:string+, +:class+).
    # @return [String] the colorized (or plain) string.
    #------------------------------------------------------------------------------
    def colorize(str, type)
      str = CGI.escapeHTML(str) if options[:html]
      if options[:plain] || !options[:color][type] || !inspector.colorize?
        str
      #
      # Check if the string color method is defined by awesome_print and accepts
      # html parameter or it has been overriden by some gem such as colorize.
      #
      elsif str.method(options[:color][type]).arity == -1 # Accepts html parameter.
        str.send(options[:color][type], options[:html])
      else
        str = %(<kbd style="color:#{options[:color][type]}">#{str}</kbd>) if options[:html]
        str.send(options[:color][type])
      end
    end
  end
end
