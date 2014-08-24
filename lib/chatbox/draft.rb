require 'securerandom'
require 'chatbox/fake_missing_keywords'

module Chatbox
  class Draft
    include FakeMissingKeywords

    def initialize(from: req(:from), to: req(:to), body: req(:body), store: req(:store), id_generator: -> { SecureRandom.uuid })
      @from = from
      @to = to
      @body = body
      @store = store
      @id_generator = id_generator
    end

    def deliver!
      store.add_message(
        'id' => id_generator.(),
        'from_id' => from.chatbox_id,
        'to_id' => to.chatbox_id,
        'body' => body,
      )
    end

    private

    attr_reader :from, :to, :body, :store, :id_generator
  end
end
