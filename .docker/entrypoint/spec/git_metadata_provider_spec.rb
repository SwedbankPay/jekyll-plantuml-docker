# frozen_string_literal: true

require 'its'
require_relative 'includes'

describe GitMetadataProvider do
  describe '#initialize' do
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
end
