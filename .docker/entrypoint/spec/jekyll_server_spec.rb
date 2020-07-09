# frozen_string_literal: true

require 'includes'

describe JekyllServer do
  describe '#initialize' do
    context 'nil config' do
      it {
        expect { JekyllServer.new(nil) }.to raise_error(ArgumentError, "#{Context} cannot be nil")
      }
    end

    context 'wrong type' do
      it {
        expect { JekyllServer.new([]) }.to raise_error(ArgumentError, "Array is not a #{Context}")
      }
    end
  end

  describe '#execute :serve' do
    data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'full')
    before(:all) do
      @thread = Thread.new do
        context = Context.new('development', __dir__, data_dir)
        jekyll_config_provider = JekyllConfigProvider.new(context)
        context.configuration = jekyll_config_provider.provide('serve')
        jekyll_server = JekyllServer.new(context)
        jekyll_server.execute
      end
      @thread.abort_on_exception = true

      JekyllServe.mutex.synchronize do
        running = JekyllServe.running?
        JekyllServe.run_cond.wait(JekyllServe.mutex) unless running
      end
    end

    after(:all) do
      JekyllServe.shutdown

      JekyllServe.mutex.synchronize do
        running = JekyllServe.running?
        JekyllServe.run_cond.wait(JekyllServe.mutex) if running
      end
    end

    describe 'weird file' do
      it {
        expect(File).not_to exist(File.join(__dir__, '..', '0.0.0.0'))
      }
    end

    describe 'site is not empty' do
      subject do
        Pathname.new(File.join(data_dir, '_site'))
      end

      it {
        is_expected.to be_directory
      }

      it {
        is_expected.to exist
      }

      it {
        is_expected.not_to be_empty
      }

    end
  end
end
