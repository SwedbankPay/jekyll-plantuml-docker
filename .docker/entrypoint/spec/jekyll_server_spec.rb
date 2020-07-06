# frozen_string_literal: true

require 'includes'

describe JekyllServer do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          JekyllServer.new(nil, :info)
        end.to raise_error(ArgumentError, 'Hash cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          JekyllServer.new({}, :info)
        end.to raise_error(ArgumentError, 'Hash cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          JekyllServer.new([], :info)
        end.to raise_error(ArgumentError, 'Array is not a Hash')
      end
    end
  end

  describe '#execute :serve' do
    describe 'weird file' do
      data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'full')

      before(:all) do
        @thread = Thread.new do
          context = Context.new('development', __dir__, data_dir)
          jekyll_config_provider = JekyllConfigProvider.new(context, :info)
          jekyll_config = jekyll_config_provider.provide('serve')
          jekyll_server = JekyllServer.new(jekyll_config, :info)
          jekyll_server.execute
        end
        @thread.abort_on_exception = true

        JekyllServe.mutex.synchronize do
          running = JekyllServe.running?
          JekyllServe.run_cond.wait(JekyllServe.mutex) unless running
        end
      end

      after(:each) do
        JekyllServe.shutdown

        JekyllServe.mutex.synchronize do
          running = JekyllServe.running?
          JekyllServe.run_cond.wait(JekyllServe.mutex) if running
        end
      end

      it {
        expect(File).not_to exist(File.join(__dir__, '..', '0.0.0.0'))
      }
    end
  end
end
