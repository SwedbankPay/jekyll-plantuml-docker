# frozen_string_literal: true

require 'includes'
require 'concurrent'

describe Verifier do
  context = Context.new('development', __dir__, __dir__)

  describe '#initialize' do
    context 'nil context' do
      it {
        expect { Verifier.new(nil) }.to raise_error(ArgumentError, "#{Context} cannot be nil")
      }
    end

    context 'wrong type' do
      it do
        expect do
          Verifier.new({})
        end.to raise_error(ArgumentError, "Hash is not a #{Context}")
      end
    end
  end

  describe '#verify' do
    data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
    site_dir = File.join(data_dir, '_site')
    context = Context.new('development', __dir__, data_dir, 'SECRET')

    before(:all) do
      jekyll_config_provider = JekyllConfigProvider.new(context)
      context.arguments = Arguments.new(
        {
          'build' => true,
          'serve' => false,
          'deploy' => false,
          '--verify' => false,
          '--dry-run' => false,
          '--ignore-url' => false,
          '--log-level' => 'error',
          '--env' => nil,
          '--profile' => nil
        }
      )
      context.configuration = jekyll_config_provider.provide('build')
      jekyll_builder = JekyllBuilder.new(context)
      jekyll_builder.execute
    end

    # before(:each) { subject.html_proofer = HTMLProofer }

    subject { Verifier.new(context) }

    context 'missing :destination' do
      it {
        allow(context).to receive(:configuration).and_return({ 'a' => 'b' })
        expect { subject.verify }.to raise_error(ArgumentError, "No 'destination' key found in the hash")
      }
    end

    context 'non-existing :destination' do
      it {
        allow(context).to receive(:configuration).and_return({ 'destination' => 'abc' })
        expect { subject.verify }.to raise_error(DirectoryNotFoundError, 'abc does not exist')
      }
    end

    it 'ignores urls' do
      ignore_urls = [ 'http://www.wikipedia.org', %r{[/.]?page1} ]
      allow(context.arguments).to receive(:ignore_urls).and_return(ignore_urls)
      subject.verify
    end

    it 'receives expected options' do
      expected_options = {
        assume_extension: true,
        check_html: true,
        check_unrendered_link: true,
        enforce_https: true,
        log_level: :error,
        only_4xx: true,
        parallel: { in_processes: Concurrent.processor_count },
        typheous: {
          verbose: false
        }
      }
      html_proofer_class = SpecHTMLProofer
      html_proofer = html_proofer_class.new
      allow(html_proofer_class).to receive(:check_directory).with(site_dir, expected_options).and_return(html_proofer)
      expect(html_proofer).to receive(:run)
      subject.html_proofer = html_proofer_class
      subject.verify
    end

    it 'sets bearer token for github' do
      ignore_urls = [ 'http://www.wikipedia.org', %r{[/.]?page1} ]
      allow(context.arguments).to receive(:ignore_urls).and_return(ignore_urls)
      logger = SpecLogger.new(:debug)
      subject.logger = logger
      subject.verify
      expect(logger.message).to include('Setting Bearer Token for GitHub request')
    end
  end
end
