require 'rails_helper'
require_relative '../../app/models/product'
require_relative '../../app/services/dynamo_db_client'

RSpec.describe Product do
  let(:dynamodb_client) { instance_double(DynamoDbClient) }
  let(:query_result) { instance_double(Aws::DynamoDB::Types::QueryOutput, items: [], last_evaluated_key: nil) }
  let(:scan_result) { instance_double(Aws::DynamoDB::Types::ScanOutput, items: []) }

  before do
    allow(DynamoDbClient).to receive(:new).and_return(dynamodb_client)
    allow(described_class).to receive(:dynamodb).and_return(dynamodb_client)
    allow(dynamodb_client).to receive_messages(query: query_result, scan: scan_result)
  end

  describe '.query_by_product_name' do
    it 'queries a product by its name' do
      described_class.query_by_product_name('product1')
      expect(dynamodb_client).to have_received(:query)
    end
  end

  describe '.all_unique_models' do
    it 'returns all unique models' do
      described_class.all_unique_models
      expect(dynamodb_client).to have_received(:scan)
    end
  end

  describe '.find_by' do
    it 'finds products by field and value' do
      described_class.find_by('name', 'product1', 'name_index', 'DETAILS')
      expect(dynamodb_client).to have_received(:query)
    end
  end
end
