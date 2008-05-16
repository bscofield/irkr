module Irkr
  class Message
    attr_accessor :line, :pattern, :match

    def initialize(line, pattern, match)
      self.line, self.match, self.pattern = line, match, pattern
    end
  end
end