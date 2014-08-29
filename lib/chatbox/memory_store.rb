require 'securerandom'
require 'time'

module Chatbox
  class MemoryStore
    def initialize(id_generator: -> { SecureRandom.uuid })
      @id_generator = id_generator
    end

    def add_message(attrs)
      attrs = attrs.merge id: id_generator.(), read_at: nil
      attrs_list << attrs
    end

    ##########

    def set_message_read_at!(id, time = Time.now)
      time = time.round(3).utc.iso8601(3) if time
      attrs_list.detect { |attrs| attrs[:id] == id }.merge! read_at: time
    end

    ##########

    def find_message(id)
      if attrs = attrs_list.detect { |attrs| attrs[:id] == id }
        Record.new attrs
      end
    end

    def find_messages_by_to_id(id)
      attrs_list.select { |attrs| attrs[:to_id] == id }.map { |attrs| Record.new attrs }
    end

    def find_messages_by_from_id(id)
      attrs_list.select { |attrs| attrs[:from_id] == id }.map { |attrs| Record.new attrs }
    end

    private

    attr_reader :id_generator

    def attrs_list
      @attrs_list ||= []
    end

    class Record
      def initialize(attrs)
        @attrs = attrs
      end

      %i[id from_id to_id body].each do |name|
        define_method name do
          attrs[name]
        end
      end

      def read_at
        Time.parse(attrs[:read_at]) if attrs[:read_at]
      end

      private

      attr_reader :attrs
    end
  end
end
