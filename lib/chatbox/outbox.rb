require 'chatbox/fake_missing_keywords'

module Chatbox
  class Outbox
    include FakeMissingKeywords

    def initialize(entity:  req(:entity), store:  req(:store))
      @id = entity.chatbox_id
      @store = store
    end

    delegate :size, :[], to: :messages

    def ==(other)
      other.is_a?(self.class) && id == other.id && store == other.store
    end

    alias_method :eql?, :==

    def hash
      id.hash ^ store.hash
    end

    protected

    attr_reader :id, :store

    private

    def messages
      @messages ||= store.find_all_messages_by_from_id id
    end
  end
end
