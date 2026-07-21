# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AwesomePrint/Sequel', skip: -> { !defined?(Sequel) }.call do
  before :all do
    if defined?(Sequel)
      @db = Sequel.sqlite
      @db.create_table(:sequel_users) do
        primary_key :id
        String :name
        Integer :rank
      end

      class SequelUser < Sequel::Model(:sequel_users)
        def validate
          super
          errors.add(:name, 'is required') if name.nil?
        end
      end
    end
  end

  after :all do
    Object.instance_eval { remove_const :SequelUser } if defined?(SequelUser)
  end

  before do
    @ap = AwesomePrint::Inspector.new(plain: true, sort_keys: true)
  end

  it 'formats a model instance as its column values' do
    user = SequelUser.new(name: 'Diana', rank: 1)
    out = @ap.awesome(user)
    expect(out).to include(':name => "Diana"')
    expect(out).to include(':rank => 1')
  end

  it 'includes validation errors for an invalid record' do
    user = SequelUser.new(rank: 1)
    user.valid?
    out = @ap.awesome(user)
    expect(out).to include(':errors =>')
    expect(out).to include(':values =>')
  end

  it 'formats a model class together with its schema' do
    out = @ap.awesome(SequelUser)
    expect(out).to match(/class\s.*SequelUser/)
    expect(out).to include(':name')
    expect(out).to include(':rank')
  end

  it 'formats a dataset as its records followed by the SQL' do
    SequelUser.insert(name: 'Diana', rank: 1)
    out = @ap.awesome(SequelUser.dataset)
    expect(out).to include('Diana')
    expect(out).to include('SELECT')
  end
end
