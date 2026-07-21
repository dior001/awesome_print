# frozen_string_literal: true

require 'spec_helper'

require 'logger'
require 'awesome_print/core_ext/logger'

RSpec.describe 'AwesomePrint logging extensions' do
  before(:all) do
    @logger = begin
      Logger.new(File::NULL)
    rescue StandardError
      Logger.new(File::NULL)
    end
  end

  describe 'ap method' do
    it 'awesome_inspects the given object' do
      object = double
      expect(object).to receive(:ai)
      @logger.ap object
    end

    describe 'the log level' do
      before do
        AwesomePrint.defaults = {}
      end

      it 'fallbacks to the default :debug log level' do
        expect(@logger).to receive(:debug)
        @logger.ap(nil)
      end

      it 'uses the global user default if no level passed' do
        AwesomePrint.defaults = { log_level: :info }
        expect(@logger).to receive(:info)
        @logger.ap(nil)
      end

      it 'uses the passed in level' do
        expect(@logger).to receive(:warn)
        @logger.ap(nil, :warn)
      end
    end
  end
end
