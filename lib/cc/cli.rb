require 'thor'

require 'cc/parser'
require 'cc/analyzer'
require 'cc/aggregated_info'
require 'cc/string'

module Cc
  class CLI < Thor
    desc "csv [pdf_path]", "Directory path of the PDF statements"
    def csv(pdf_path)
      output_dir = ask("Where should the file be saved? (default: #{Cc::results_dir}/)", path: true)

      if !output_dir.blank? && !File.directory?(output_dir)
        say "#{output_dir} does not exist."
        return 1
      end

      proceed = yes?("
        Statements will be from #{pdf_path}.
        Output will be saved in #{output_dir}.
        Proceed?
      ")

      exit 1 if !proceed

      output_dir = output_dir.blank? ? nil : output_dir
      parser = Parser.new(pdf_path, output_dir: output_dir)
      say 'Parsing...'
      parser.execute

      say "Your CSV is here: #{parser.output_file}"
      say "Bye."
    end

    desc "eval [pdf_path]", "Directory path of the PDF statements"
    def eval(pdf_path)
      output_dir = ask("Where should the file be saved? (default: #{Cc::results_dir}/)", path: true)

      if !output_dir.blank? && !File.directory?(output_dir)
        say "#{output_dir} does not exist."
        return 1
      end

      proceed = yes?("
        Statements will be from #{pdf_path}.
        Output will be saved in #{output_dir}.
        Proceed?
      ")

      exit 1 if !proceed

      output_dir = output_dir.blank? ? nil : output_dir
      parser = Parser.new(pdf_path, output_dir: output_dir)
      say 'Parsing...'
      parser.execute

      say "CSV generated here: #{parser.output_file}"
      analyzer = Analyzer.new(parser.output_file, output_dir: output_dir)
      say 'Analyzing...'
      analyzer.execute

      say "Your CSV is here: #{parser.output_file}"
      say "Your JSON is here: #{analyzer.json_file}"
      say "Bye."
    end
  end
end
