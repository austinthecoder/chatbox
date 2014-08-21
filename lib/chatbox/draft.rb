module Chatbox
  class Draft
    def initialize(from:, to:, body:, store:)
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
