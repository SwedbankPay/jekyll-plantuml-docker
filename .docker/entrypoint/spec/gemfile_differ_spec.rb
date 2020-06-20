# frozen_string_literal: true

require 'gemfile-differ'

describe Jekyll::PlantUml::GemfileDiffer do
  subject(:differ) { Jekyll::PlantUml::GemfileDiffer.new }

  describe '#diff' do
    let(:primary_gemfile_path) { File.join(__dir__, 'Gemfile.primary') }
    let(:secondary_gemfile_path) { File.join(__dir__, 'Gemfile.secondary') }

    context 'non-existent primary gemfile' do
      it 'should raise' do
        expect { differ.diff('abc', secondary_gemfile_path) }.to raise_error 'abc cannot be found.'
      end
    end

    context 'non-existent secondary gemfile' do
      it {
        expect(differ.diff(primary_gemfile_path, 'xyz')).to be_empty
      }
      specify { expect { |b| differ.diff(primary_gemfile_path, 'xyz', &b) }.not_to yield_control }
    end

    context 'two existing files' do
      specify do
        expect do |line|
          differ.diff(primary_gemfile_path, secondary_gemfile_path, &line)
        end.to yield_control.exactly(11).times
      end
      specify do
        expect do |line|
          differ.diff(primary_gemfile_path, secondary_gemfile_path, &line)
        end.to yield_successive_args(
          "gem \"jekyll\", \"~> 4.1\", group: :jekyll_plugins\n",
          "gem \"jekyll-assets\"\n",
          "gem \"jemoji\"\n",
          "gem \"faraday\", \"~> 1.0.1\"\n",
          "gem \"jekyll-material-icon-tag\"\n",
          "gem \"kramdown-plantuml\"\n",
          "gem \"jekyll-github-metadata\"\n",
          "gem \"docopt\"\n",
          "gem \"html-proofer\"\n",
          "gem \"html-proofer-unrendered-markdown\"\n",
          "gem \"rouge\"\n"
        )
      end
    end
  end
end
