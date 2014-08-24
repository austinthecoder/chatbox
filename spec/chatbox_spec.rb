describe Chatbox do
  describe '.deliver_message!' do
    before do
      @from = double 'entity', chatbox_id: 1
      @to = double 'entity', chatbox_id: 2
      @draft = double 'draft', deliver!: nil
      allow(Chatbox::Draft).to receive(:new).and_return @draft
    end

    it 'instantiates a draft with the configured store' do
      store = double 'store'
      Chatbox.configure { |config| config.store = store }
      expect(Chatbox::Draft).to receive(:new).with from: @from, to: @to, body: 'Hi', store: store
      Chatbox.deliver_message! from: @from, to: @to, body: 'Hi'
    end

    it 'delivers the draft' do
      expect(@draft).to receive :deliver!
      Chatbox.deliver_message! from: @from, to: @to, body: 'Hi'
    end
  end

  describe '.fetch_inbox_for' do
    it 'returns an inbox for the entity and configured store' do
      store = double 'store'
      Chatbox.configure { |config| config.store = store }
      entity = double 'entity', chatbox_id: 1
      expect(Chatbox.fetch_inbox_for(entity)).to eq Chatbox::Inbox.new(entity: entity, store: store)
    end
  end

  describe '.fetch_outbox_for' do
    it 'returns an outbox for the entity and configured store' do
      store = double 'store'
      Chatbox.configure { |config| config.store = store }
      entity = double 'entity', chatbox_id: 1
      expect(Chatbox.fetch_outbox_for(entity)).to eq Chatbox::Outbox.new(entity: entity, store: store)
    end
  end
end
