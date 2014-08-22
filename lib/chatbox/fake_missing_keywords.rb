module Chatbox
  module FakeMissingKeywords
    def req(keyword)
      raise ArgumentError, "at least one missing keyword: #{keyword}"
    end
  end
end
