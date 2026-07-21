# frozen_string_literal: true

# Copyright (c) 2010-2016 Michael Dvorkin and contributors
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'awesome_print/version'

Gem::Specification.new do |s|
  s.name        = 'awesome_print'
  s.version     = AwesomePrint.version
  s.authors     = ['Michael Dvorkin']
  s.email       = 'mike@dvorkin.net'
  s.homepage    = 'https://github.com/awesome-print/awesome_print'
  s.summary     = 'Pretty print Ruby objects with proper indentation and colors'
  s.description = 'Great Ruby debugging companion: pretty print Ruby objects ' \
                  'to visualize their structure. Supports custom object ' \
                  'formatting via plugins.'
  s.license     = 'MIT'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/awesome-print/awesome_print/issues',
    'changelog_uri' => 'https://github.com/awesome-print/awesome_print/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/awesome-print/awesome_print',
    'rubygems_mfa_required' => 'true'
  }

  s.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + ['.gitignore']
  s.require_paths = ['lib']

  # Awesome Print is intentionally dependency-free at runtime: it relies only
  # on the Ruby standard library so it can be dropped into any project.
  s.required_ruby_version = '>= 2.7'

  s.add_development_dependency 'bundler-audit', '~> 0.9'
  s.add_development_dependency 'nokogiri', '>= 1.11'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.13'
  s.add_development_dependency 'rubocop', '~> 1.60'
  s.add_development_dependency 'rubocop-rake', '~> 0.6'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.add_development_dependency 'sequel', '~> 5.0'
  s.add_development_dependency 'simplecov', '~> 0.22'
  s.add_development_dependency 'sqlite3', '>= 1.4'
end
