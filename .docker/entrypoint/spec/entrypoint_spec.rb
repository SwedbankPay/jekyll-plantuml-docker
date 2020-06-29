# frozen_string_literal: true

require 'entrypoint'
require 'docker_image'
require 'jekyll_environment'

describe Jekyll::PlantUml::Entrypoint do
  subject(:entrypoint) do
    data_dir = File.join(__dir__, 'data')
    Jekyll::PlantUml::Entrypoint.new(
      Jekyll::PlantUml::JekyllEnvironment.new('dev', data_dir, data_dir),
      Jekyll::PlantUml::DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
    )
  end

  it {
    is_expected.not_to be_nil
  }

  describe '#execute' do
    it { expect { entrypoint.execute }.to_not raise_error }
  end
end
