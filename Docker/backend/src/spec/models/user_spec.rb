require 'rails_helper'
require_relative '../../app/models/user'

RSpec.describe User do
  describe '.find_by' do
    let(:user_id) { 'user1' }
    let(:dynamodb_client) { instance_double(Aws::DynamoDB::Client) }

    before do
      allow(Aws::DynamoDB::Client).to receive(:new).and_return(dynamodb_client)
      allow(described_class).to receive(:dynamodb).and_return(dynamodb_client)
      allow(dynamodb_client).to receive(:get_item).and_return(instance_double(Aws::DynamoDB::Types::GetItemOutput, item: {}))
    end

    it 'fetches the user by id' do
      described_class.find_by(user_id)
      expect(dynamodb_client).to have_received(:get_item).with({
                                                                 table_name: 'TapFindCase',
                                                                 key: {
                                                                   PK: user_id,
                                                                   SK: 'USER'
                                                                 }
                                                               })
    end
  end

  describe '.find_or_create_by_cookie_id' do
    let(:cookie_id) { 'cookie1' }
    let(:uuid) { SecureRandom.uuid }

    context 'when user does not exist' do
      let(:dynamodb_client) { instance_double(Aws::DynamoDB::Client) }

      before do
        allow(Aws::DynamoDB::Client).to receive(:new).and_return(dynamodb_client)
        allow(described_class).to receive(:dynamodb).and_return(dynamodb_client)
        allow(dynamodb_client).to receive(:query).and_return(instance_double(Aws::DynamoDB::Types::QueryOutput, items: []))
        allow(SecureRandom).to receive(:uuid).and_return(uuid)
        allow(dynamodb_client).to receive(:put_item)
      end

      it 'creates a new user' do
        described_class.find_or_create_by_cookie_id(cookie_id)
        expect(dynamodb_client).to have_received(:put_item).with({
                                                                   table_name: 'TapFindCase',
                                                                   item: {
                                                                     'PK' => uuid,
                                                                     'SK' => 'USER',
                                                                     'cookie_id' => cookie_id
                                                                   }
                                                                 })
      end
    end

    context 'when user exists' do
      let(:dynamodb_client) { instance_double(Aws::DynamoDB::Client) }

      before do
        allow(Aws::DynamoDB::Client).to receive(:new).and_return(dynamodb_client)
        allow(described_class).to receive(:dynamodb).and_return(dynamodb_client)
        allow(dynamodb_client).to receive(:query).and_return(instance_double(Aws::DynamoDB::Types::QueryOutput, items: [{}]))
      end

      it 'fetches the existing user' do
        described_class.find_or_create_by_cookie_id(cookie_id)
        expect(dynamodb_client).to have_received(:query).with({
                                                                table_name: 'TapFindCase',
                                                                index_name: 'cookie_id_index',
                                                                key_condition_expression: 'cookie_id = :cookie_id',
                                                                expression_attribute_values: { ':cookie_id' => cookie_id }
                                                              })
      end
    end
  end
end
