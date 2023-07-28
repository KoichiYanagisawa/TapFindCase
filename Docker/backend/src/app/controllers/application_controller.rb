# frozen_string_literal: true

require 'aws-sdk-s3'

class ApplicationController < ActionController::API
  def generate_presigned_url(key)
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    signer = Aws::S3::Presigner.new(client: s3_client)
    url = signer.presigned_url(:get_object, bucket: ENV['BACKEND_AWS_S3_BUCKET'], key: key, expires_in: 600)
    url.to_s
  end
end
