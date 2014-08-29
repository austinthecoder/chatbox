require 'dalli'
require 'chatbox/memcached_store'
require 'chatbox/memory_store'

describe 'stores' do
  [:memcached, :memory].each do |store_type|
    context "using #{store_type} store" do
      before do
        id = 0
        id_generator = -> { id += 1 }
        @store = case store_type
        when :memcached
          client = Dalli::Client.new nil, namespace: 'chatbox-test'
          client.flush
          Chatbox::MemcachedStore.new client, id_generator: id_generator
        when :memory
          Chatbox::MemoryStore.new id_generator: id_generator
        end

        [
          {from_id: 20, to_id: 30, body: 'Hi'},
          {from_id: 20, to_id: 31, body: 'Hello'},
          {from_id: 21, to_id: 31, body: 'Howdy'},
        ].each do |attrs|
          @store.add_message attrs
        end

        @values_list = [
          {id: 1, from_id: 20, to_id: 30, body: 'Hi', read_at: nil},
          {id: 2, from_id: 20, to_id: 31, body: 'Hello', read_at: nil},
          {id: 3, from_id: 21, to_id: 31, body: 'Howdy', read_at: nil},
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

      it 'changing message read_at' do
        read_at = Time.new
        @store.set_message_read_at! 1, read_at
        message = @store.find_message 1
        expect(message.read_at).to eq read_at.round(3)

        @store.set_message_read_at! 1, nil
        message = @store.find_message 1
        expect(message.read_at).to be_nil
      end
    end
  end
end
