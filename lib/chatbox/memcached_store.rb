require 'json'

module Chatbox
  class MemcachedStore
    def initialize(client)
      @client = client
    end

    def add_message(attrs)
      client.set "messages/#{attrs['id']}", JSON.generate(
        'from_id' => attrs['from_id'],
        'to_id' => attrs['to_id'],
        'body' => attrs['body'],
        'read' => false,
      )

      from_list = JSON.parse(client.get("from/#{attrs['from_id']}") || '[]')
      from_list << {'from_id' => attrs['from_id'], 'message_id' => attrs['id']}
      client.set "from/#{attrs['from_id']}", JSON.generate(from_list)

      to_list = JSON.parse(client.get("to/#{attrs['to_id']}") || '[]')
      to_list << {'to_id' => attrs['to_id'], 'message_id' => attrs['id']}
      client.set "to/#{attrs['to_id']}", JSON.generate(to_list)
    end

    ##########

    def mark_message_read!(id)
      attrs = JSON.parse client.get("messages/#{id}")
      attrs['read'] = true
      client.set "messages/#{id}", JSON.generate(attrs)
    end

    def mark_message_unread!(id)
      attrs = JSON.parse client.get("messages/#{id}")
      attrs['read'] = false
      client.set "messages/#{id}", JSON.generate(attrs)
    end

    ##########

    def find_message(id)
      if json = client.get("messages/#{id}")
        Record.new id, JSON.parse(json)
      end
    end

    def find_messages_by_to_id(id)
      if json = client.get("to/#{id}")
        JSON.parse(json).map do |attrs|
          find_message attrs['message_id']
        end
      else
        []
      end
    end

    def find_messages_by_from_id(id)
      if json = client.get("from/#{id}")
        JSON.parse(json).map do |attrs|
          find_message attrs['message_id']
        end
      else
        []
      end
    end

    private

    attr_reader :client

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
