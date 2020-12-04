# frozen_string_literal: true

require 'its'
require_relative 'includes'

describe GitMetadataProvider do
  describe '#initialize' do
    context 'values extracted from context' do
      data_dir = File.join(__dir__, 'data')
      branch = 'my_favorite_branch'
      repo = 'https://example.com/SwedbankPay/nice_repository'

      subject do
        context = Context.new('development', __dir__, data_dir, git_branch: branch, git_repository_url: repo)
        GitMetadataProvider.new(context)
      end

      its(:branch) { is_expected.to eq branch }
      its(:repository_url) { is_expected.to eq repo }
    end

    context 'git URL is translated' do
      data_dir = File.join(__dir__, 'data')

      subject do
        context = Context.new(
          'development',
          __dir__,
          data_dir,
          git_branch: 'master',
          git_repository_url: 'git@github.com:SwedbankPay/nice_repository.git')
        GitMetadataProvider.new(context)
      end

      its(:repository_url) { is_expected.to eq 'https://github.com/SwedbankPay/nice_repository' }
    end

    context 'values extracted from Git' do
      data_dir = File.join(__dir__, 'data')

      subject do
        context = Context.new('development', __dir__, data_dir)
        GitMetadataProvider.new(context)
      end

      its(:branch) { is_expected.not_to be_empty }
      its(:repository_url) { is_expected.to eq 'https://github.com/SwedbankPay/jekyll-plantuml-docker' }
    end
  end
end
