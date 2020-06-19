require "gemfile-generator"

describe Jekyll::PlantUml::GemfileGenerator do
  subject(:generator) { Jekyll::PlantUml::GemfileGenerator.new }

  describe "#generate" do
    let(:primary_gemfile_path) { File.join(__dir__, "Gemfile.primary") }
    let(:secondary_gemfile_path) { File.join(__dir__, "Gemfile.secondary") }
    let(:generated_gemfile_path) { File.join(__dir__, "Gemfile.generated") }

    context "non-existent primary gemfile" do
      it "should raise" do
        expect { generator.generate("abc", "efg", "xyz") }.to raise_error ("abc cannot be found.")
      end
    end

    context "non-existent secondary gemfile" do
      it "should raise" do
        expect { generator.generate(primary_gemfile_path, "efg", "xyz") }.to raise_error ("efg cannot be found.")
      end
    end

    context "existing gemfiles" do
      let(:_) {
        generator.generate(primary_gemfile_path, secondary_gemfile_path, generated_gemfile_path)
      }
      it {
        expect(File).to exist(generated_gemfile_path)
      }
    end
  end
end
