# frozen_string_literal: true

# Copyright (c) 2010-2016 Michael Dvorkin and contributors
#
# Awesome Print is freely distributable under the terms of MIT license.
# See LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module AwesomePrint
  module ActiveRecord
    def self.included(base)
      base.send :alias_method, :cast_without_active_record, :cast
      base.send :alias_method, :cast, :cast_with_active_record
    end

    # Add ActiveRecord class names to the dispatcher pipeline.
    #------------------------------------------------------------------------------
    def cast_with_active_record(object, type)
      cast = cast_without_active_record(object, type)
      return cast unless defined?(::ActiveRecord::Base)

      if object.is_a?(::ActiveRecord::Base)
        cast = :active_record_instance
      elsif object.is_a?(::ActiveModel::Errors)
        cast = :active_model_error
      elsif object.is_a?(Class) && object.ancestors.include?(::ActiveRecord::Base)
        cast = :active_record_class
      elsif type == :activerecord_relation || object.class.ancestors.include?(::ActiveRecord::Relation)
        cast = :array
      end
      cast
    end

    private

    # Format ActiveRecord instance object.
    #
    # NOTE: by default only instance attributes (i.e. columns) are shown. To format
    # ActiveRecord instance as regular object showing its instance variables and
    # accessors use :raw => true option:
    #
    # ap record, :raw => true
    #
    #------------------------------------------------------------------------------
    def awesome_active_record_instance(object)
      return object.inspect unless defined?(::ActiveSupport)
      return awesome_object(object) if @options[:raw]

      "#{object} #{awesome_hash(active_record_attributes_hash(object))}"
    end

    # Build a hash of an ActiveRecord instance's attributes. When the record
    # carries columns that are not part of its schema (ex. a `SELECT` with
    # custom columns) the raw attribute hash is returned as-is; otherwise the
    # schema column order is honored.
    #------------------------------------------------------------------------------
    def active_record_attributes_hash(object)
      return object.attributes if object.class.column_names != object.attributes.keys

      object.class.column_names.each_with_object({}) do |name, hash|
        next unless object.has_attribute?(name) || object.new_record?

        hash[name.to_sym] = object.respond_to?(name) ? object.send(name) : object.read_attribute(name)
      end
    end

    # Format ActiveRecord class object.
    #------------------------------------------------------------------------------
    def awesome_active_record_class(object)
      if !defined?(::ActiveSupport) || !object.respond_to?(:columns) || object.to_s == 'ActiveRecord::Base'
        return object.inspect
      end
      return awesome_class(object) if object.respond_to?(:abstract_class?) && object.abstract_class?

      data = object.columns.to_h do |c|
        [c.name.to_sym, c.type]
      end

      name = "class #{awesome_simple(object.to_s, :class)}"
      base = "< #{awesome_simple(object.superclass.to_s, :class)}"

      [name, base, awesome_hash(data)].join(' ')
    end

    # Format ActiveModel error object.
    #------------------------------------------------------------------------------
    def awesome_active_model_error(object)
      return object.inspect unless defined?(::ActiveSupport)
      return awesome_object(object) if @options[:raw]

      # ActiveModel::Errors#marshal_dump was removed in Rails 7/8; reach the
      # model the errors belong to through its @base instance variable instead.
      base = object.instance_variable_get(:@base)
      data = active_record_attributes_hash(base)
      data.merge!(details: object.details, messages: object.messages)
      "#{object} #{awesome_hash(data)}"
    end
  end
end

AwesomePrint::Formatter.include AwesomePrint::ActiveRecord
