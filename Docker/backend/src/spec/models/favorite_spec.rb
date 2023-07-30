require 'rails_helper'
require_relative '../../app/models/favorite'
require_relative '../../app/services/dynamo_db_client'
require 'aws-sdk-dynamodb'

RSpec.describe Favorite do
  let(:user_id) { 'user1' }
  let(:product_id) { 'product1' }
  let(:dynamodb_client) { instance_double(DynamoDbClient) }
  let(:put_item_result) { instance_double(Aws::DynamoDB::Types::PutItemOutput) }
  let(:delete_item_result) { instance_double(Aws::DynamoDB::Types::DeleteItemOutput) }
  let(:get_item_result) { instance_double(Aws::DynamoDB::Types::GetItemOutput, item: nil) }
  let(:query_result) { instance_double(Aws::DynamoDB::Types::QueryOutput, items: []) }

  before do
    allow(DynamoDbClient).to receive(:new).and_return(dynamodb_client)
    allow(described_class).to receive(:dynamodb).and_return(dynamodb_client)
    allow(dynamodb_client).to receive(:put_item).and_return(put_item_result)
    allow(dynamodb_client).to receive(:delete_item).and_return(delete_item_result)
    allow(dynamodb_client).to receive(:get_item).and_return(get_item_result)
    allow(dynamodb_client).to receive(:query).and_return(query_result)
  end

  describe '.create' do
    it 'creates a new favorite' do
      result = described_class.create(user_id:, product_id:)
      expect(dynamodb_client).to have_received(:put_item)
      expect(result).to eq({ 'product_id' => product_id })
    end
  end

  describe '.destroy' do
    it 'destroys a favorite' do
      described_class.destroy(user_id:, product_id:)
      expect(dynamodb_client).to have_received(:delete_item)
    end
  end

  describe '.find_by' do
    it 'finds a favorite by user_id and product_id' do
      described_class.find_by(user_id:, product_id:)
      expect(dynamodb_client).to have_received(:get_item)
    end
  end

  describe '.find_by_user_and_case' do
    it 'finds a favorite by user_id and case_name' do
      described_class.find_by_user_and_case(user_id:, case_name: 'some_case')
      expect(dynamodb_client).to have_received(:query)
    end
  end

  describe '.find_all_by_user' do
    it 'finds all favorites by user_id' do
      described_class.find_all_by_user(user_id:)
      expect(dynamodb_client).to have_received(:query)
    end
  end
end
