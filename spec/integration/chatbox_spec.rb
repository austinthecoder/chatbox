require 'dalli'
require 'chatbox/memcached_store'

describe 'chatbox' do
  before do
    @austin = double 'entity', chatbox_id: 1
    @rachel = double 'entity', chatbox_id: 2
  end

  [:memcached, :memory].each do |store_type|
    context "using #{store_type} store" do
      before do
        if store_type == :memcached
          client = Dalli::Client.new nil, namespace: 'chatbox-test'
          client.flush
          Chatbox.configure { |config| config.store = Chatbox::MemcachedStore.new client }
        end
      end

      it 'sending a message' do
        Chatbox.deliver_message! from: @austin, to: @rachel, body: 'Hello! How are you?'

        austins_outbox = Chatbox.fetch_outbox @austin
        expect(austins_outbox.size).to eq 1

        message = austins_outbox[0]
        expect(message.to_id).to eq 2
        expect(message.body).to eq 'Hello! How are you?'
      end

      it 'receiving a message' do
        Chatbox.deliver_message! from: @austin, to: @rachel, body: 'Hello! How are you?'

        rachels_inbox = Chatbox.fetch_inbox @rachel
        expect(rachels_inbox.size).to eq 1

        message = rachels_inbox[0]
        expect(message.from_id).to eq 1
        expect(message.body).to eq 'Hello! How are you?'
      end

      it 'marking messages as read/unread' do
        Chatbox.deliver_message! from: @austin, to: @rachel, body: 'Hello! How are you?'

        message = Chatbox.fetch_inbox(@rachel)[0]

        expect(message).to_not be_read

        message.mark_as_read!
        expect(message).to be_read

        message = Chatbox.fetch_inbox(@rachel)[0]

        expect(message).to be_read

        message.mark_as_unread!
        expect(message).to_not be_read

        message = Chatbox.fetch_inbox(@rachel)[0]

        expect(message).to_not be_read
      end
    end
  end
end
