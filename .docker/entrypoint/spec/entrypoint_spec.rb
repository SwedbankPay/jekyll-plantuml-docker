# frozen_string_literal: true

require 'entrypoint'
require 'docker_image'
require 'jekyll_environment'

Entrypoint = Jekyll::PlantUml::Entrypoint
JekyllEnvironment = Jekyll::PlantUml::JekyllEnvironment
DockerImage = Jekyll::PlantUml::DockerImage

describe Entrypoint do
  subject(:entrypoint) do
    data_dir = File.join(__dir__, 'data')
    Entrypoint.new(
      JekyllEnvironment.new('dev', data_dir, data_dir),
      DockerImage.new('jekyll-plantuml', 'latest', '1.2.3')
    )
  end

  it {
    is_expected.not_to be_nil
  }

  describe '#execute' do
    it { expect { entrypoint.execute }.to_not raise_error }
  end
end
