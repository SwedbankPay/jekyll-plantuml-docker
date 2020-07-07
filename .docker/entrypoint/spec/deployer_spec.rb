# frozen_string_literal: true

require 'includes'

describe Deployer do
  subject(:deployer) do
    data_dir = File.join(__dir__, 'data')
    context = Context.new('development', data_dir, data_dir)
    Deployer.new(context)
  end

  describe '#deploy' do
    subject! { deployer.jekyll_build = SpecJekyllBuild.new }
    it { expect { deployer.deploy }.to invoke(:process).on(subject).at_least(1).times }
  end
end
