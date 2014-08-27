require 'dalli'
require 'chatbox/memcached_store'
require 'chatbox/memory_store'

describe 'stores' do
  [:memcached, :memory].each do |store_type|
    context "using #{store_type} store" do
      before do
        @store = case store_type
        when :memcached
          client = Dalli::Client.new nil, namespace: 'chatbox-test'
          client.flush
          Chatbox::MemcachedStore.new client
        when :memory
          Chatbox::MemoryStore.new
        end

        [
          {'id' => 1, 'from_id' => 20, 'to_id' => 30, 'body' => 'Hi'},
          {'id' => 2, 'from_id' => 20, 'to_id' => 31, 'body' => 'Hello'},
          {'id' => 3, 'from_id' => 21, 'to_id' => 31, 'body' => 'Howdy'},
        ].each do |attrs|
          @store.add_message attrs
        end

        @values_list = [
          {id: 1, from_id: 20, to_id: 30, body: 'Hi', read: false},
          {id: 2, from_id: 20, to_id: 31, body: 'Hello', read: false},
          {id: 3, from_id: 21, to_id: 31, body: 'Howdy', read: false},
        ]
      end

      it 'finding messages by id' do
        [1, 2, 3].each_with_index do |id, index|
          message = @store.find_message id
          @values_list[index].each do |name, value|
            expect(message.public_send name).to eq value
          end
        end
      end

      it 'finding messages by to_id' do
        messages = @store.find_messages_by_to_id 30
        expect(messages.size).to eq 1
        message = messages[0]
        @values_list[0].each do |name, value|
          expect(message.public_send name).to eq value
        end

        messages = @store.find_messages_by_to_id 31
        expect(messages.size).to eq 2
        [
          [messages[0], @values_list[1]],
          [messages[1], @values_list[2]],
        ].each do |message, values|
          values.each do |name, value|
            expect(message.public_send name).to eq value
          end
        end
      end

      it 'finding messages by from_id' do
        messages = @store.find_messages_by_from_id 21
        expect(messages.size).to eq 1
        message = messages[0]
        @values_list[2].each do |name, value|
          expect(message.public_send name).to eq value
        end

        messages = @store.find_messages_by_from_id 20
        expect(messages.size).to eq 2
        [
          [messages[0], @values_list[0]],
          [messages[1], @values_list[1]],
        ].each do |message, values|
          values.each do |name, value|
            expect(message.public_send name).to eq value
          end
        end
      end

      it 'marking messages as read/unread' do
        @store.mark_message_read! 1
        message = @store.find_message 1
        expect(message.read).to eq true

        @store.mark_message_unread! 1
        message = @store.find_message 1
        expect(message.read).to eq false
      end
    end
  end
end
