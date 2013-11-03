require "arel_converter/version"
require 'ruby2ruby'
require 'ruby_parser'
require 'logging'

$:.unshift(File.dirname(__FILE__))

require File.join('arel_converter', 'base')
require File.join('arel_converter', 'command')
require File.join('arel_converter', 'formatter')
require File.join('arel_converter', 'active_record_finder')
require File.join('arel_converter', 'scope')
require File.join('arel_converter', 'association')

# Translators
require File.join('arel_converter', 'translators', 'base')
require File.join('arel_converter', 'translators', 'options')
require File.join('arel_converter', 'translators', 'scope')
require File.join('arel_converter', 'translators', 'finder')
require File.join('arel_converter', 'translators', 'association')

module ArelConverter

end
