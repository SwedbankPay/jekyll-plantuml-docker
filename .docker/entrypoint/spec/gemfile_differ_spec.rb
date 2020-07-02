# frozen_string_literal: true

require 'bundler'
require 'gemfile_differ'
require 'errors/file_not_found_error'

GemfileDiffer = Jekyll::PlantUml::GemfileDiffer
FileNotFoundError = Jekyll::PlantUml::FileNotFoundError

describe GemfileDiffer do
  subject(:differ) { GemfileDiffer.new }

  describe '#diff' do
    let(:user_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.user') }
    let(:default_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.default') }

    context 'non-existent default gemfile' do
      it 'should raise' do
        expect do
          differ.diff('abc', user_gemfile_path)
        end.to raise_error(FileNotFoundError, 'abc cannot be found.')
      end
    end

    context 'non-existent user gemfile' do
      specify do
        expect do |b|
          differ.diff(default_gemfile_path, 'xyz', &b)
        end.to yield_control.exactly(11).times
      end

      specify do
        expect do |b|
          differ.diff(default_gemfile_path, 'xyz', &b)
        end.to yield_expected_dependencies
      end
    end

    context 'existing gemfiles' do
      specify do
        expect do |b|
          differ.diff(default_gemfile_path, user_gemfile_path, &b)
        end.to yield_control.exactly(11).times
      end

      specify do
        expect do |b|
          differ.diff(default_gemfile_path, user_gemfile_path, &b)
        end.to yield_expected_dependencies
      end
    end

    def dependency(name, requirements = nil)
      Bundler::Dependency.new(name, requirements)
    end

    def yield_expected_dependencies(*_args)
      yield_successive_args(
        dependency('jekyll', '~> 4.1'),
        dependency('jekyll-assets'),
        dependency('jemoji'),
        dependency('faraday', '~> 1.0.1'),
        dependency('jekyll-material-icon-tag'),
        dependency('kramdown-plantuml'),
        dependency('jekyll-github-metadata'),
        dependency('docopt'),
        dependency('html-proofer'),
        dependency('html-proofer-unrendered-markdown'),
        dependency('rouge')
      )
    end
  end
end
