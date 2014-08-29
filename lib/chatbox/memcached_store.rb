require 'securerandom'
require 'json'
require 'time'

module Chatbox
  class MemcachedStore
    def initialize(client, id_generator: -> { SecureRandom.uuid })
      @client = client
      @id_generator = id_generator
    end

    def add_message(attrs)
      id = id_generator.()

      write "messages/#{id}", {
        from_id: attrs[:from_id],
        to_id: attrs[:to_id],
        body: attrs[:body],
        sent_at: Time.new.round(3).utc.iso8601(3),
      }

      from_list = read("from/#{attrs[:from_id]}") || []
      from_list << {from_id: attrs[:from_id], message_id: id}
      write "from/#{attrs[:from_id]}", from_list

      to_list = read("to/#{attrs[:to_id]}") || []
      to_list << {to_id: attrs[:to_id], message_id: id}
      write "to/#{attrs[:to_id]}", to_list
    end

    ##########

    def set_message_read_at!(id, time = Time.now)
      time = time.round(3).utc.iso8601(3) if time
      attrs = read "messages/#{id}"
      attrs[:read_at] = time
      write "messages/#{id}", attrs
    end

    ##########

    def find_message(id)
      if attrs = read("messages/#{id}")
        Record.new id, attrs
      end
    end

    def find_messages_by_to_id(id)
      if attrs_list = read("to/#{id}")
        attrs_list.map do |attrs|
          find_message attrs[:message_id]
        end
      else
        []
      end
    end

    def find_messages_by_from_id(id)
      if attrs_list = read("from/#{id}")
        attrs_list.map do |attrs|
          find_message attrs[:message_id]
        end
      else
        []
      end
    end

    private

    attr_reader :client, :id_generator

    def read(key)
      if value = client.get(key)
        JSON.parse value, symbolize_names: true
      end
    end

    def write(key, value)
      client.set key, JSON.generate(value)
    end

    class Record
      def initialize(id, attrs)
        @id = id
        @attrs = attrs
      end

      attr_reader :id

      %i[from_id to_id body].each do |name|
        define_method name do
          attrs[name]
        end
      end

      def read_at
        @read_at ||= Time.parse(attrs[:read_at]) if attrs[:read_at]
      end

      def sent_at
        @sent_at ||= Time.parse attrs[:sent_at]
      end

      private

      attr_reader :attrs
    end
  end
end
