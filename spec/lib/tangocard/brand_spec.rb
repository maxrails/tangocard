require 'spec_helper'

describe TangoCard::Brand do
  include TangocardHelpers

  describe 'class methods' do
    let (:rewards_index) { TangoCard::Response.new(double(parsed_response: sample_parsed_response, code: 200))}

    before do
      allow(TangoCard::Raas).to receive(:rewards_index) { rewards_index }
    end

    describe 'self.all' do
      context 'Tangocard is behaving' do
        it 'should return an array of TangoCard::Brand objects' do
          all_brands = TangoCard::Brand.all
          expect(all_brands).to be_a(Array)
          expect(all_brands.map(&:class).uniq.count).to eq 1
          expect(all_brands.map(&:class).uniq.first).to eq TangoCard::Brand
        end
      end

      context 'Tangocard is failing us' do
        before do
          allow(TangoCard::Raas).to receive(:rewards_index) { TangoCard::Response.new(double(parsed_response: nil, code: 500)) }
        end

        it 'should raise a sensible error' do
          expect { TangoCard::Brand.all }.to raise_error(TangoCard::RaasException)
        end
      end
    end

    describe 'self.find' do
      it 'should return the first brand whose description matches the brand_name' do
        expect(TangoCard::Brand.find('Amazon.com').class).to eq TangoCard::Brand
        expect(TangoCard::Brand.find('Amazon.com').description).to eq 'Amazon.com'
      end
    end

    describe 'self.default' do
      before do
        Tangocard.configure do |c|
          c.default_brands = ['Amazon.com', 'Prepaid Virtual Visa', 'invalid']
        end
      end

      it 'should return array of default TangoCard::Brand objects' do
        default_brands = TangoCard::Brand.default
        expect(default_brands).to be_a(Array)
        expect(default_brands.count).to eq 2
        expect(default_brands.map(&:class).uniq.count).to eq 1
        expect(default_brands.map(&:class).uniq.first).to eq TangoCard::Brand
      end
    end
  end

  describe 'instance methods' do
    let(:description) { Object.new }
    let(:image_url) { Object.new }
    let(:reward) { Object.new }
    let(:params) { {'description' => description, 'image_url' => image_url, 'rewards' => [reward]} }
    let(:variable_brand) { TangoCard::Brand.new(sample_brand_variable) }
    let(:fixed_brand) { TangoCard::Brand.new(sample_brand_fixed) }
    let(:cents) { 500 }

    describe 'initialize' do
      it 'should initialize the description' do
        allow(TangoCard::Reward).to receive(:new).with(reward) { true }
        brand = TangoCard::Brand.new(params)
        expect(brand.description).to eq description
      end

      it 'should initialize the image_url' do
        allow(TangoCard::Reward).to receive(:new).with(reward) { true }
        brand = TangoCard::Brand.new(params)
        expect(brand.image_url).to eq image_url
      end

      it 'should initialize the reward(s)' do
        expect(TangoCard::Reward).to receive(:new).with(reward) { true }
        TangoCard::Brand.new(params)
      end
    end

    describe 'image_url' do
      it 'should return a local override image, if present' do
        allow(TangoCard::Reward).to receive(:new).with(reward) { true }
        allow_any_instance_of(TangoCard::Configuration).to receive(:local_images) { { description => 'local' } }
        brand = TangoCard::Brand.new(params)
        expect(brand.image_url).to eq 'local'
      end

      it 'should return image_url if no local override image' do
        allow(TangoCard::Reward).to receive(:new).with(reward) { true }
        allow_any_instance_of(TangoCard::Configuration).to receive(:local_images) { {} }
        brand = TangoCard::Brand.new(params)
        expect(brand.image_url).to eq image_url
      end
    end

    describe 'purchasable_rewards' do
      it 'should return all purchasable rewards' do
        fixed_brand.rewards.each_with_index do |r, i|
          expect(r).to receive(:purchasable?).with(cents) { i.even? }
        end

        purchasable = fixed_brand.purchasable_rewards(cents)
        fixed_brand.rewards.each_with_index do |r, i|
          expect(purchasable.include?(r)).to be true if i.even?
        end
      end
    end

    describe 'has_purchasable_rewards?' do
      context 'has purchasable rewards' do
        before do
          allow(fixed_brand).to receive(:purchasable_rewards).with(cents) { [:a, :b] }
        end

        it 'should return true' do
          fixed_brand.has_purchasable_rewards?(cents).should be true
        end
      end

      context 'no purchasable rewards' do
        before do
          allow(fixed_brand).to receive(:purchasable_rewards).with(cents) { [] }
        end

        it 'should return false' do
          fixed_brand.has_purchasable_rewards?(cents).should be false
        end
      end
    end

    describe 'variable_price?' do
      it 'should return true if variable priced rewards are available' do
        variable_brand.variable_price?.should be true
      end

      it 'should return false if no variable priced rewards are available' do
        fixed_brand.variable_price?.should be false
      end
    end
  end
end
