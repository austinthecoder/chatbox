module Chatbox
  class MemoryStore
    def add_message(message)
      messages << message
    end

    def find_all_messages_by_to_id(to_id)
      messages.select { |message| message.to_id == to_id }
    end

    def find_all_messages_by_from_id(from_id)
      messages.select { |message| message.from_id == from_id }
    end

    private

    def messages
      @messages ||= []
    end
  end
end
