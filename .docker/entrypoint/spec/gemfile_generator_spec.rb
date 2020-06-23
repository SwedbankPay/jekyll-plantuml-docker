# frozen_string_literal: true

require 'gemfile_generator'
require 'diffy'

describe Jekyll::PlantUml::GemfileGenerator do
  subject(:generator) { Jekyll::PlantUml::GemfileGenerator.new }

  describe '#generate' do
    let(:primary_gemfile_path) { File.join(__dir__, 'Gemfile.primary') }
    let(:secondary_gemfile_path) { File.join(__dir__, 'Gemfile.secondary') }
    let(:generated_gemfile_path) { File.join(__dir__, 'Gemfile.generated') }

    after(:each) do
      File.delete generated_gemfile_path if File.exist? generated_gemfile_path
    end

    context 'non-existent primary gemfile' do
      it 'should raise' do
        expect do
          generator.generate(
            'abc',
            secondary_gemfile_path,
            generated_gemfile_path
          )
        end.to raise_error 'abc cannot be found.'
      end
    end

    context 'non-existent secondary gemfile' do
      let!(:_) do
        generator.generate(primary_gemfile_path, 'efg', generated_gemfile_path)
      end
      subject { File.read(generated_gemfile_path) }
      it {
        expect(File).to exist(generated_gemfile_path)
      }
      it {
        is_expected.not_to include('gem "rouge"')
        is_expected.to include('gem "open3"')
      }
    end

    context 'existing gemfiles' do
      let!(:_) do
        generator.generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
      end
      subject { File.read(generated_gemfile_path) }
      it {
        expect(File).to exist(generated_gemfile_path)
      }
      it {
        is_expected.to include('gem "rouge"')
      }
    end

    context 'identical content with primary' do
      subject { generator.generate(primary_gemfile_path, primary_gemfile_path) }
      subject(:primary_gemfile_contents) { File.read(primary_gemfile_path) }
      it {
        is_expected.to equal(primary_gemfile_contents)
      }
    end

    context 'identical content with secondary' do
      subject { generator.generate(secondary_gemfile_path, secondary_gemfile_path) }
      subject(:secondary_gemfile_contents) { File.read(secondary_gemfile_path) }
      it {
        is_expected.to equal(secondary_gemfile_contents)
      }
    end

    context 'diff with primary' do
      let!(:_) do
        generator.generate(primary_gemfile_path, primary_gemfile_path, generated_gemfile_path)
      end
      subject do
        Diffy::Diff.new(primary_gemfile_path, generated_gemfile_path, source: 'files').to_s
      end
      it {
        is_expected.to be_empty
      }
    end

    context 'diff with secondary' do
      let!(:_) do
        generator.generate(secondary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
      end
      subject do
        Diffy::Diff.new(secondary_gemfile_path, generated_gemfile_path, source: 'files').to_s
      end
      it {
        is_expected.to be_empty
      }
    end
  end
end
