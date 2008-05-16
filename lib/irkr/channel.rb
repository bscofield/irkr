module Irkr
  class Channel
    attr_accessor :name, :topic, :users
    
    def initialize(name)
      self.name = name
    end
  end
end