require 'active_support/core_ext/object'
require 'chatbox/configuration'
require 'chatbox/draft'
require 'chatbox/inbox'
require 'chatbox/memory_store'
require 'chatbox/outbox'
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

  def fetch_inbox(entity)
    Inbox.new entity: entity, store: store
  end

  def fetch_outbox(entity)
    Outbox.new entity: entity, store: store
  end

  private

  def config
    @config ||= Configuration.new
  end

  def store
    @store ||= config.store || MemoryStore.new
  end
end
