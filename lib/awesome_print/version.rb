# frozen_string_literal: true

# Copyright (c) 2010-2016 Michael Dvorkin and contributors
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module AwesomePrint
  # The gem's semantic version. Bumped to 2.0.0 for the modernization release,
  # which drops abandoned ORM integrations (mongo_mapper, ripple, nobrainer)
  # and support for end-of-life Ruby versions (< 2.7).
  def self.version
    '2.0.0'
  end
end
