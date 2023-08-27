require "openapm/version"

module Openapm
  class Error < StandardError; end

  @@default_labels = { program: 'web-application' }

  def self.default_labels=(labels = {})
    @@default_labels = labels
  end

  def self.default_labels
    @@default_labels
  end
end
