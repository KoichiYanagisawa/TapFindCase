require 'rails_helper'
require_relative '../../app/models/history'
require_relative '../../app/services/dynamo_db_client'

RSpec.describe History, type: :model do
  let(:user_id) { 'user1' }
  let(:product_name) { 'product1' }
  let(:viewed_at) { Time.now.iso8601 }

  describe '.create_or_update' do
    context 'when history does not exist' do
      let(:dynamodb_client) { instance_double('DynamoDbClient') }

      before do
        allow(DynamoDbClient).to receive(:new).and_return(dynamodb_client)
        allow(History).to receive(:dynamodb).and_return(dynamodb_client)
        allow(dynamodb_client).to receive(:get_item).and_return(double('Aws::DynamoDB::Types::GetItemOutput', item: nil))
        allow(dynamodb_client).to receive(:put_item)
      end

      it 'creates a new history' do
        History.create_or_update(user_id, product_name, viewed_at)
        expect(dynamodb_client).to have_received(:put_item)
      end
    end

    context 'when history exists' do
      let(:dynamodb_client) { instance_double('DynamoDbClient') }

      before do
        allow(DynamoDbClient).to receive(:new).and_return(dynamodb_client)
        allow(History).to receive(:dynamodb).and_return(dynamodb_client)
        allow(dynamodb_client).to receive(:get_item).and_return(double('Aws::DynamoDB::Types::GetItemOutput', item: {}))
        allow(dynamodb_client).to receive(:update_item)
      end

      it 'updates the existing history' do
        History.create_or_update(user_id, product_name, viewed_at)
        expect(dynamodb_client).to have_received(:update_item)
      end
    end
  end
end
