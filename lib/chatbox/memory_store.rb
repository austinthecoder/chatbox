module Chatbox
  class MemoryStore
    def add_message(attrs)
      attrs_list << attrs.merge('read' => false)
    end

    ##########

    def mark_message_read!(id)
      attrs_list.detect { |attrs| attrs['id'] == id }.merge! 'read' => true
    end

    def mark_message_unread!(id)
      attrs_list.detect { |attrs| attrs['id'] == id }.merge! 'read' => false
    end

    ##########

    def find_message(id)
      if attrs = attrs_list.detect { |attrs| attrs['id'] == id }
        Record.new attrs
      end
    end

    def find_messages_by_to_id(id)
      attrs_list.select { |attrs| attrs['to_id'] == id }.map { |attrs| Record.new attrs }
    end

    def find_messages_by_from_id(id)
      attrs_list.select { |attrs| attrs['from_id'] == id }.map { |attrs| Record.new attrs }
    end

    private

    def attrs_list
      @attrs_list ||= []
    end

    class Record
      def initialize(attrs)
        @attrs = attrs
      end

      %w[id from_id to_id body read].each do |name|
        define_method name do
          attrs[name]
        end
      end

      private

      attr_reader :attrs
    end
  end
end
