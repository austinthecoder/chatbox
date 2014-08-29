require 'active_support/core_ext/object'
require 'chatbox/configuration'
require 'chatbox/draft'
require 'chatbox/memory_store'
require 'chatbox/message'
require 'chatbox/version'

module Chatbox
  extend self

  def configure
    yield config
  end

  def reset_config!
    @config = nil
    @store = nil
  end

  def deliver_message!(args)
    args.merge! store: store
    Draft.new(args).deliver!
  end

  def find_messages_from(sender)
    records = store.find_messages_by_from_id sender.chatbox_id
    records.map { |record| Message.new record: record, store: store }
  end

  def find_messages_to(recipient)
    records = store.find_messages_by_to_id recipient.chatbox_id
    records.map { |record| Message.new record: record, store: store }
  end

  private

  def config
    @config ||= Configuration.new
  end

  def store
    @store ||= config.store || MemoryStore.new
  end
end
