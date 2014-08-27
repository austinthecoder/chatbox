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
      )

      expect(store).to receive(:add_message).with from_id: 1, to_id: 2, body: 'Hi'
      draft.deliver!
    end
  end
end
