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
    buffer = StringIO.new
    
    before(:each) do
      @thread = Thread.new do
        context = Context.new('development', __dir__, data_dir)
        jekyll_config_provider = JekyllConfigProvider.new(context)
        context.configuration = jekyll_config_provider.provide('serve')
        jekyll_server = JekyllServer.new(context)

        logger = Logger.new(buffer)
        jekyll_server.logger = logger

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

      buffer.rewind
      puts buffer.string.to_s
    end

    describe 'weird file' do
      weird_filename = '0.0.0.0'
      it {
        expect(File).not_to exist(File.join(__dir__, weird_filename))
      }
      it {
        expect(File).not_to exist(File.join(__dir__, '..', weird_filename))
      }
      it {
        expect(File).not_to exist(File.join(data_dir, weird_filename))
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
        expect(Dir.empty? subject).to eq(false)
      }

      it {
        expect(Dir.entries(subject)).to include('index.html')
      }
    end
  end
end
