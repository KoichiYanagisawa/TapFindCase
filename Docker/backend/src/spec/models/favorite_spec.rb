# require 'rails_helper'
# require_relative '../../app/models/favorite'

# RSpec.describe Favorite, type: :model do
#   let(:user_id) { 'user1' }
#   let(:product_id) { 'product1' }
#   let(:case_name) { 'case1' }

#   describe '.create' do
#     it 'creates a new favorite' do
#       expect(Favorite.create(user_id: user_id, product_id: product_id)).to eq({ 'product_id' => product_id })
#     end
#   end

#   describe '.destroy' do
#     it 'deletes a favorite' do
#       Favorite.create(user_id: user_id, product_id: product_id)
#       Favorite.destroy(user_id: user_id, product_id: product_id)
#       expect(Favorite.find_by(user_id: user_id, product_id: product_id)).to be_nil
#     end
#   end

#   describe '.find_by' do
#     it 'finds a favorite by user_id and product_id' do
#       Favorite.create(user_id: user_id, product_id: product_id)
#       expect(Favorite.find_by(user_id: user_id, product_id: product_id)).not_to be_nil
#     end
#   end

#   describe '.find_by_user_and_case' do
#     it 'finds a favorite by user_id and case_name' do
#       Favorite.create(user_id: user_id, product_id: case_name)
#       expect(Favorite.find_by_user_and_case(user_id: user_id, case_name: case_name)).to be_truthy
#     end
#   end

#   describe '.find_all_by_user' do
#     it 'finds all favorites by user_id' do
#       Favorite.create(user_id: user_id, product_id: product_id)
#       expect(Favorite.find_all_by_user(user_id: user_id)).to include(product_id)
#     end
#   end
# end
