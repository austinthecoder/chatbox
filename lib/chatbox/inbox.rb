require 'chatbox/fake_missing_keywords'
require 'chatbox/message'

module Chatbox
  class Inbox
    include FakeMissingKeywords

    def initialize(entity: req(:entity), store: req(:store))
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
      @messages ||= begin
        records = store.find_all_messages_by_to_id id
        records.map { |record| Message.new record: record, store: store }
      end
    end
  end
end
