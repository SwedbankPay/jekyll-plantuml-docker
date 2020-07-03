# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::GemfileGeneratorExec do
  let(:user_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.user') }
  let(:default_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.default') }
  let(:generated_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.generated') }

  subject(:generator) do
    GemfileGeneratorExec.new(
      {
        default: default_gemfile_path,
        user: user_gemfile_path,
        generated: generated_gemfile_path
      }
    )
  end

  describe '#generate' do
    after(:each) do
      File.delete generated_gemfile_path if File.exist? generated_gemfile_path
    end

    context 'existing gemfiles' do
      let!(:_) do
        generator.generate
      end
      subject { File.read(generated_gemfile_path) }
      it {
        expect(File).to exist(generated_gemfile_path)
      }
      it {
        is_expected.not_to be_empty
      }
      it {
        is_expected.to include("gem 'open3'")
      }
      it {
        is_expected.to include("gem 'rouge'")
      }
      it {
        expect(generated_gemfile_path).to be_valid_gemfile
      }
    end
  end
end
