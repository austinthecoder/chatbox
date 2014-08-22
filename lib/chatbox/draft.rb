require 'chatbox/fake_missing_keywords'

module Chatbox
  class Draft
    include FakeMissingKeywords

    def initialize(from: req(:from), to: req(:to), body: req(:body), store: req(:store))
      @from_id = from.chatbox_id
      @to_id = to.chatbox_id
      @body = body
      @store = store
    end

    attr_reader :to_id, :from_id, :body

    def deliver!
      store.add_message self
    end

    private

    attr_reader :store
  end
end
