# frozen_string_literal: true

load 'includes.rb'

describe Jekyll::PlantUml::GemfileGenerator do
  subject(:generator) { GemfileGenerator.new }

  describe '#generate' do
    let(:user_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.user') }
    let(:default_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.default') }
    let(:generated_gemfile_path) { File.join(__dir__, 'data', 'Gemfile.generated') }

    after(:each) do
      File.delete generated_gemfile_path if File.exist? generated_gemfile_path
    end

    context 'non-existent default gemfile' do
      it 'should raise' do
        expect do
          generator.generate('abc', user_gemfile_path, generated_gemfile_path)
        end.to raise_error(FileNotFoundError, 'abc cannot be found.')
      end
    end

    context 'non-existent user gemfile' do
      let!(:_) do
        generator.generate(default_gemfile_path, 'efg', generated_gemfile_path)
      end
      subject { File.read(generated_gemfile_path) }
      it {
        expect(File).to exist(generated_gemfile_path)
      }
      it {
        is_expected.not_to be_empty
      }
      it {
        is_expected.to include("gem 'rouge'")
      }
      it {
        is_expected.not_to include("gem 'open3'")
      }
    end

    context 'existing gemfiles' do
      let!(:_) do
        generator.generate(default_gemfile_path, user_gemfile_path, generated_gemfile_path)
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

    context 'identical content with user gemfile' do
      subject { generator.generate(user_gemfile_path, user_gemfile_path) }
      subject(:user_gemfile_contents) { File.read(user_gemfile_path) }
      it {
        is_expected.to equal(user_gemfile_contents)
      }
      it {
        is_expected.to include("gem 'open3'")
      }
    end

    context 'identical content with default gemfile' do
      subject { generator.generate(default_gemfile_path, default_gemfile_path) }
      subject(:default_gemfile_contents) { File.read(default_gemfile_path) }
      it {
        is_expected.to equal(default_gemfile_contents)
      }
      it {
        is_expected.to include("gem 'rouge'")
      }
    end

    context 'diff with user gemfile' do
      let!(:_) do
        generator.generate(user_gemfile_path, user_gemfile_path, generated_gemfile_path)
      end
      subject do
        Diff.new(user_gemfile_path, generated_gemfile_path, source: 'files').to_s
      end
      it {
        is_expected.to be_empty
      }
    end

    context 'diff with default gemfile' do
      let!(:_) do
        generator.generate(default_gemfile_path, default_gemfile_path, generated_gemfile_path)
      end
      subject do
        Diff.new(default_gemfile_path, generated_gemfile_path, source: 'files').to_s
      end
      it {
        is_expected.to be_empty
      }
    end
  end
end
