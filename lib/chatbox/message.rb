require 'chatbox/fake_missing_keywords'

module Chatbox
  class Message
    include FakeMissingKeywords

    def initialize(record: req(:record), store: req(:store))
      @record = record
      @store = store
    end

    delegate :id, :from_id, :to_id, :body, to: :record

    def read?
      record.read_at
    end

    def mark_as_read!
      store.set_message_read_at! id
      @record = store.find_message id
    end

    def mark_as_unread!
      store.set_message_read_at! id, nil
      @record = store.find_message id
    end

    def ==(other)
      other.is_a?(self.class) && record == other.record && store == other.store
    end

    private

    attr_reader :record, :store
  end
end
