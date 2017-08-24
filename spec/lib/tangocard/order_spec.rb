require 'spec_helper'

describe TangoCard::Order do
  include TangocardHelpers

  describe 'class methods' do
    describe 'self.all' do
      let(:params) { Object.new }
      let(:success_response) { sample_order_index_response(true) }
      let(:fail_response) { sample_order_index_response(false) }

      it 'should return an array of TangoCard::Order objects if successful' do
        expect(TangoCard::Raas).to receive(:orders_index).with(params) { success_response }
        expect(TangoCard::Order).to receive(:new).with(success_response.parsed_response['orders'].first) { true }
        TangoCard::Order.all(params).should == [true]
      end

      it 'should return an empty array if unsuccessful' do
        expect(TangoCard::Raas).to receive(:orders_index).with(params) { fail_response }
        TangoCard::Order.all(params).should == []
      end
    end

    describe 'self.find' do
      let(:order_id) { Object.new }
      let(:success_response) { sample_find_order_response(true) }
      let(:fail_response) { sample_find_order_response(false) }

      it 'should return a TangoCard::Order object if successful' do
        expect(TangoCard::Raas).to receive(:show_order).with({'order_id' => order_id}) { success_response }
        expect(TangoCard::Order).to receive(:new).with(success_response.parsed_response['order'], success_response) { true }
        expect(TangoCard::Order.find(order_id)).to be true
      end

      it 'should throw a TangoCard::OrderNotFoundException if failed' do
        expect(TangoCard::Raas).to receive(:show_order).with({'order_id' => order_id}) { fail_response }
        lambda{ TangoCard::Order.find(order_id) }.should raise_error(TangoCard::OrderNotFoundException)
      end
    end

    describe 'self.create' do
      let(:params) { Object.new }
      let(:success_response) { sample_create_order_response(true) }
      let(:fail_response) { sample_create_order_response(false) }

      it 'should return at TangoCard::Order object if successful' do
        expect(TangoCard::Raas).to receive(:create_order).with(params) { success_response }
        expect(TangoCard::Order).to receive(:new).with(success_response.parsed_response['order'], success_response) { true }
        expect(TangoCard::Order.create(params)).to be true
      end

      it 'should throw a TangoCard::OrderCreateFailedException if failed' do
        expect(TangoCard::Raas).to receive(:create_order).with(params) { fail_response }
        lambda{ TangoCard::Order.create(params) }.should raise_error(TangoCard::OrderCreateFailedException)
      end
    end
  end

  describe 'instance methods' do
    describe 'initialize' do
      let(:params) { Object.new }

      it 'should set the attributes on the object' do
        expect(params).to receive(:[]).with('order_id') { 'order_id' }
        expect(params).to receive(:[]).with('account_identifier') { 'account_identifier' }
        expect(params).to receive(:[]).with('customer') { 'customer' }
        expect(params).to receive(:[]).with('sku') { 'sku' }
        expect(params).to receive(:[]).with('denomination') { 'denomination' }
        expect(params).to receive(:[]).with('amount_charged') { 'amount_charged' }
        expect(params).to receive(:[]).with('reward_message') { 'reward_message' }
        expect(params).to receive(:[]).with('reward_subject') { 'reward_subject' }
        expect(params).to receive(:[]).with('reward_from') { 'reward_from' }
        expect(params).to receive(:[]).with('delivered_at') { 'delivered_at' }
        expect(params).to receive(:[]).with('recipient') { 'recipient' }
        expect(params).to receive(:[]).with('external_id') { 'recipient' }
        expect(params).to receive(:[]).with('reward') { 'reward' }

        TangoCard::Order.send(:new, params)
      end
    end

    describe 'reward' do
      pending 'TODO'
    end

    describe 'identifier' do
      pending 'TODO'
    end
  end
end
