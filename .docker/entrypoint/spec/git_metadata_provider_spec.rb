# frozen_string_literal: true

require 'its'
require_relative 'includes'

describe GitMetadataProvider do
  describe '#initialize' do
    let(:ctx) do
      data_dir = File.join(__dir__, 'data')
      Context.new('development', __dir__, data_dir)
    end

    context 'values extracted from context' do
      branch = 'my_favorite_branch'
      repo = 'https://example.com/SwedbankPay/nice_repository'

      subject do
        ctx.git_branch = branch
        ctx.git_repository_url = repo
        GitMetadataProvider.new(ctx)
      end

      its(:branch) { is_expected.to eq branch }
      its(:repository_url) { is_expected.to eq repo }
    end

    context 'git URL is translated' do
      subject do
        ctx.git_branch = 'master'
        ctx.git_repository_url = 'git@github.com:SwedbankPay/nice_repository.git'
        GitMetadataProvider.new(ctx)
      end

      its(:repository_url) { is_expected.to eq 'https://github.com/SwedbankPay/nice_repository' }
    end

    context 'values extracted from Git' do
      subject do
        GitMetadataProvider.new(ctx)
      end

      its(:branch) { is_expected.not_to be_empty }
      its(:repository_url) { is_expected.to eq 'https://github.com/SwedbankPay/jekyll-plantuml-docker' }
    end
  end
end
