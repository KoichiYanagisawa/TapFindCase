# frozen_string_literal: true

require 'aws-sdk-s3'

class ApplicationController < ActionController::API
  def generate_presigned_url(key)
    s3_client = Aws::S3::Client.new(
      region: ENV.fetch('MY_AWS_REGION', nil),
      access_key_id: ENV.fetch('MY_AWS_ACCESS_KEY_ID', nil),
      secret_access_key: ENV.fetch('MY_AWS_SECRET_ACCESS_KEY', nil)
    )

    signer = Aws::S3::Presigner.new(client: s3_client)
    url = signer.presigned_url(:get_object, bucket: ENV.fetch('BACKEND_AWS_S3_BUCKET', nil), key:, expires_in: 600)
    url.to_s
  end
end
