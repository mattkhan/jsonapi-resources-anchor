require "thor"

class SnapshotUpdate < Thor
  include Thor::Actions

  def self.prompt(...) = new.prompt(...)

  desc "prompt", "Prompt user to update snapshot"
  def prompt(...) = create_file(...)
end
