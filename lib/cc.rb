require "cc/version"
require 'cc'
require 'cc/cli'

require 'pdf/reader'
require "awesome_print"
require "smarter_csv"
require "json"


module Cc
  def self.root
    File.dirname __dir__
  end

  def self.results_dir
    File.join root, 'results'
  end
end
