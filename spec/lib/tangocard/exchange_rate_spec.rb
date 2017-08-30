require 'spec_helper'

describe TangoCard::ExchangeRate do
  include TangocardHelpers

  describe 'class methods' do

    describe 'self.timestamp' do
      before do
        allow(TangoCard::Raas).to receive(:rewards_index) { double(parsed_response: sample_parsed_response) }
      end

      it 'should return timestamp' do
        expect(TangoCard::ExchangeRate.timestamp).to eq 1456956187
      end
    end

    describe 'self.all' do
      before do
        allow(TangoCard::Raas).to receive(:rewards_index) { double(parsed_response: sample_parsed_response) }
      end

      it 'should return an array of TangoCard::ExchangeRate objects' do
        all_rates = TangoCard::ExchangeRate.all
        all_rates.should be_a(Array)
        expect(all_rates.map(&:class).uniq.count).to eq 1
        expect(all_rates.map(&:class).uniq.first).to eq TangoCard::ExchangeRate
      end
    end

    describe 'self.find' do
      before do
        allow(TangoCard::Raas).to receive(:rewards_index) { double(parsed_response: sample_parsed_response) }
      end

      it 'should return exchange rate which matches currency_code' do
        expect(TangoCard::ExchangeRate.find('EUR').class).to eq TangoCard::ExchangeRate
        expect(TangoCard::ExchangeRate.find('EUR').rate).to eq 0.8887
      end
    end

    describe 'self.populate_money_rates' do
      it 'should set all available exchange rate for Money' do
        allow(TangoCard::ExchangeRate).to receive(:all) { [TangoCard::ExchangeRate.new('EUR', 2)] }
        expect(Money).to receive(:add_rate).with('EUR', 'USD', 0.50)
        expect(TangoCard::ExchangeRate.populate_money_rates).to eq true
      end
    end
  end

  describe 'instance methods' do
    let(:currency_code) { 'USD' }
    let(:rate) { '5' }
    let(:params) { [currency_code, rate] }

    describe 'initialize' do
      it 'should initialize the currency_code' do
        exchange_rate = TangoCard::ExchangeRate.new(*params)
        expect(exchange_rate.currency_code).to eq 'USD'
      end

      it 'should initialize the rate' do
        exchange_rate = TangoCard::ExchangeRate.new(*params)
        expect(exchange_rate.rate).to eq 5.0
      end
    end

    describe 'inverse_rate' do
      it 'should return an inverse calculated rate' do
        exchange_rate = TangoCard::ExchangeRate.new(*params)
        expect(exchange_rate.inverse_rate).to eq 0.2
      end
    end
  end
end
