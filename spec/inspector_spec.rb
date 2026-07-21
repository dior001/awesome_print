# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe AwesomePrint::Inspector do
  describe 'loading ~/.aprc' do
    before do
      @home = Dir.mktmpdir
      @original_home = ENV.fetch('HOME', nil)
      ENV['HOME'] = @home
      # Undo the global stub so the real dotfile logic runs.
      allow_any_instance_of(described_class).to receive(:load_dotfile).and_call_original
    end

    after do
      ENV['HOME'] = @original_home
      AwesomePrint.defaults = nil
      FileUtils.remove_entry(@home)
    end

    it 'merges options defined in the dotfile' do
      File.write(File.join(@home, '.aprc'), 'AwesomePrint.defaults = { plain: true, indent: 1 }')
      inspector = described_class.new
      expect(inspector.options[:plain]).to eq(true)
      expect(inspector.options[:indent]).to eq(1)
    end

    it 'does nothing when the dotfile is absent' do
      inspector = described_class.new
      expect(inspector.options[:plain]).to eq(false)
    end

    it 'rescues and reports errors raised while loading the dotfile' do
      File.write(File.join(@home, '.aprc'), 'raise "boom"')
      expect { described_class.new }
        .to output(/Could not load '\.aprc'.*boom/).to_stderr
    end
  end

  describe '#colorize?' do
    around do |example|
      original = AwesomePrint.force_colors
      example.run
      AwesomePrint.force_colors = original
    end

    it 'is true when colors are forced regardless of TTY' do
      AwesomePrint.force_colors!(true)
      expect(described_class.new.colorize?).to eq(true)
    end
  end
end
