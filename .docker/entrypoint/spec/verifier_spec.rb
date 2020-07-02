# frozen_string_literal: true

require 'exec_env'
require 'jekyll_config_provider'
require 'commands/verifier'
require 'commands/jekyll_commander'
require 'errors/directory_not_found_error'

# rubocop:disable Style/MixinUsage
include Jekyll::PlantUml
include Jekyll::PlantUml::Commands
# rubocop:enable Style/MixinUsage

describe Jekyll::PlantUml::Commands::Verifier do
  describe '#initialize' do
    context 'nil config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new(nil, :error)
        end.to raise_error(ArgumentError, 'Value cannot be nil')
      end
    end

    context 'empty config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({}, :error)
        end.to raise_error(ArgumentError, 'Hash cannot be empty')
      end
    end

    context 'non-hash config' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new([], :error)
        end.to raise_error(ArgumentError, 'Array is not a Hash')
      end
    end

    context 'missing :destination' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({ a: 'b' }, :error)
        end.to raise_error(ArgumentError, "No 'destination' key found in the hash")
      end
    end

    context 'non-existing :destination' do
      it do
        expect do
          Jekyll::PlantUml::Commands::Verifier.new({ 'destination' => 'abc' }, :erro)
        end.to raise_error(DirectoryNotFoundError, 'abc does not exist')
      end
    end
  end

  describe '#verify' do
    data_dir = File.join(__dir__, '..', '..', '..', 'tests', 'minimal')
    site_dir = File.join(data_dir, '_site')

    before(:all) do
      exec_env = ExecEnv.new('development', __dir__, data_dir)
      jekyll_config_provider = JekyllConfigProvider.new(exec_env, :error)
      jekyll_config = jekyll_config_provider.provide('build')
      jekyll_commander = JekyllCommander.new(jekyll_config, :error)
      jekyll_commander.execute('build')
    end

    subject { Verifier.new({ 'destination' => site_dir }, :error) }

    it 'ignores urls' do
      ignore_urls = [ 'http://www.wikipedia.org', %r{[/.]?page1} ]
      subject.verify(ignore_urls)
    end
  end
end
