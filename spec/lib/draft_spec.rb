require 'chatbox/draft'

describe Chatbox::Draft do
  describe 'deliver!' do
    it 'tells the store to add a message' do
      store = double 'store'
      draft = Chatbox::Draft.new(
        from: double('entity', chatbox_id: 1),
        to: double('entity', chatbox_id: 2),
        body: 'Hi',
        store: store,
        id_generator: -> { 'b00c7e15-668b-44b8-9336-e87e7b7d892e' },
      )

      expect(store).to receive(:add_message).with(
        'id' => 'b00c7e15-668b-44b8-9336-e87e7b7d892e',
        'from_id' => 1,
        'to_id' => 2,
        'body' => 'Hi',
      )
      draft.deliver!
    end
  end
end
