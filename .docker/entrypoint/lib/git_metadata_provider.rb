# frozen_string_literal: true

require_relative 'context'
require_relative 'extensions/object_extensions'
require_relative 'extensions/string_extensions'

# The Jekyll module contains everything related to Jekyll.
module Jekyll
  # The Jekyll::PlantUml module contains everything related to Jekyll::PlantUml.
  module PlantUml
    # The Jekyll::PlantUml::GitMetadataProvider class provides metadata from
    # Git, such as the name of the current branch and the 'origin' repository URL
    class GitMetadataProvider
      attr_accessor :logger

      def initialize(context)
        context.must_be_a! Context
        @context = context
      end

      def branch
        @branch ||= find_branch
      rescue StandardError => e
        log(:error, e)
        nil
      end

      def repository_url
        @repository_url ||= find_repository_url
      rescue StandardError => e
        log(:error, e)
        nil
      end

      private

      def find_branch
        git_branch = @context.git_branch || git('rev-parse --abbrev-ref HEAD')
        git_parent_commits = `git show --no-patch --format="%P"`.split

        if git_parent_commits.length > 1
          # We have more than 1 parent, so this is a merge-commit
          log(:debug, 'Merge-commit detected. Finding parents.')

          git_first_parent_branch = git_first_parent_branch(git_parent_branches)

          return git_first_parent_branch unless git_first_parent_branch.nil? || git_first_parent_branch.empty?
        else
          log(:debug, "No merge commit, moving along with branch '#{git_branch}'.")
        end

        git_branch
      end

      def find_repository_url
        git_repo_url = @context.git_repository_url || git('config --get remote.origin.url')

        # Translate from SSH to HTTPS URL.
        /^git@github\.com:(?<repo_name>.*)\.git$/.match(git_repo_url) do |match|
          repo_name = match[:repo_name]
          git_repo_url = "https://github.com/#{repo_name}"
        end

        git_repo_url
      end

      def git_first_parent_branch(git_parent_commits)
        git_parent_branches = git_parent_commits.map do |git_parent_commit|
          git_parent_branch = `git describe --contains --always --all --exclude refs/tags/ #{git_parent_commit}`
          git_parent_branch.strip!

          return git_parent_branch unless git_parent_branch.include?('~') || git_parent_branch.include?('^')
        end

        git_parent_branches.compact.first
      end

      def git(git_command)
        `git #{git_command}`.safe_strip
      end

      def log(severity, message)
        (@logger ||= Jekyll.logger).public_send(
          severity,
          "   jekyll-plantuml: #{message}"
        )
      end
    end
  end
end
