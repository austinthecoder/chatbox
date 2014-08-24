require 'dalli'
require 'json'

module Chatbox
  class MemcachedStore
    def initialize(namespace: nil)
      @dalli = Dalli::Client.new nil, namespace: namespace
    end

    delegate :flush, to: :dalli

    def add_message(attrs)
      @dalli.set "messages/#{attrs['id']}", JSON.generate(
        'from_id' => attrs['from_id'],
        'to_id' => attrs['to_id'],
        'body' => attrs['body'],
      )

      from_list = JSON.parse(@dalli.get("from/#{attrs['from_id']}") || '[]')
      from_list << {'from_id' => attrs['from_id'], 'message_id' => attrs['id']}
      @dalli.set "from/#{attrs['from_id']}", JSON.generate(from_list)

      to_list = JSON.parse(@dalli.get("to/#{attrs['to_id']}") || '[]')
      to_list << {'to_id' => attrs['to_id'], 'message_id' => attrs['id']}
      @dalli.set "to/#{attrs['to_id']}", JSON.generate(to_list)
    end

    ##########

    def mark_message_read!(id)
      attrs = JSON.parse @dalli.get("messages/#{id}")
      attrs['read'] = true
      @dalli.set "messages/#{id}", JSON.generate(attrs)
    end

    def mark_message_unread!(id)
      attrs = JSON.parse @dalli.get("messages/#{id}")
      attrs['read'] = false
      @dalli.set "messages/#{id}", JSON.generate(attrs)
    end

    ##########

    def find_message(id)
      if json = @dalli.get("messages/#{id}")
        Record.new id, JSON.parse(json)
      end
    end

    def find_all_messages_by_to_id(id)
      if json = @dalli.get("to/#{id}")
        JSON.parse(json).map do |attrs|
          find_message attrs['message_id']
        end
      else
        []
      end
    end

    def find_all_messages_by_from_id(id)
      if json = @dalli.get("from/#{id}")
        JSON.parse(json).map do |attrs|
          find_message attrs['message_id']
        end
      else
        []
      end
    end

    private

    attr_reader :dalli

    class Record
      def initialize(id, attrs)
        @id = id
        @attrs = attrs
      end

      attr_reader :id

      %w[from_id to_id body read].each do |name|
        define_method name do
          attrs[name]
        end
      end

      private

      attr_reader :attrs
    end
  end
end
