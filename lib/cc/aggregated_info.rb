module Cc
  class AggregatedInfo
    L = 15
    attr_reader :key, :chars, :trimmed_chars
    def initialize(chars)
      @chars = chars
      @trimmed_chars = trim_chars!
      @key = trimmed_chars.downcase.gsub(" ","_")
    end

    def trim_chars!
      if chars.length > L
        chars[0..L]
      else
        chars
      end
    end
  end
end
