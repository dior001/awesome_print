# frozen_string_literal: true

SimpleCov.start do
  add_filter '/spec/'
  enable_coverage :branch if respond_to?(:enable_coverage)
  track_files 'lib/**/*.rb'

  # Every shipped line must be exercised by the suite.
  minimum_coverage line: 100
end
