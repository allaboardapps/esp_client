require 'json'
require 'openssl'
require 'rest-client'

class ContributionUploader
  CHUNK_SIZE = 1024 * 1024 * 10 # 10MB (Must be at least 5MB)

  def initialize(file, mime_type, submission_batch_id, token)
    @file = file
    @mime_type = mime_type
    @submission_batch_id = submission_batch_id
    @token = token
  end

  def upload(bucket, filename)
    initiate_upload(bucket, filename)
    etags = upload_chunks
    complete_upload(etags)
    @contribution_id
  end

  private

  def initiate_upload(bucket, filename)
    uri = URI("#{CREDENTIALS["base_uri"]}/ingestion/v1/contributions")
    payload = {
      submission_batch_id: @submission_batch_id,
      upload_bucket: bucket,
      file_name: filename,
      mime_type: @mime_type
    }

    client = RequestClient.new(payload, uri, @token)
    response = client.post
    file_data = JSON.parse(response.body)
    @contribution_id = file_data['contribution_id']
  end

  def upload_chunks
    etags = []
    part_number = 0
    until @file.eof?
      part_number += 1
      file_chunk = @file.read(CHUNK_SIZE)
      etag = upload_chunk(part_number, file_chunk)
      etags << { part_number: part_number.to_s, etag: etag }
    end
    etags
  end

  def upload_chunk(part_number, file_chunk)
    encrypted_payload = encrypt(file_chunk)
    chunk_data = get_chunk_headers(part_number, encrypted_payload)
    response = RestClient.put(chunk_data['upload_url'], file_chunk, chunk_data['headers'])
    response.headers[:etag]
  end

  def encrypt(value)
    digest = OpenSSL::Digest::SHA256.new
    if value.respond_to?(:read)
      chunk = nil
      chunk_size = 1024 * 1024 # 1 megabyte
      digest.update(chunk) while chunk = value.read(chunk_size)
      value.rewind
    else
      digest.update(value)
    end
    digest.hexdigest
  end

  def get_chunk_headers(part_number, encrypted_payload)
    uri = URI("#{CREDENTIALS["base_uri"]}/ingestion/v1/contributions/#{
    @contribution_id}/authorize_chunk")
    payload = {
      id: @contribution_id,
      encrypted_payload: encrypted_payload,
      part_number: part_number
    }

    client = RequestClient.new(payload, uri, @token)
    response = client.get
    JSON.parse(response.body)
  end

  def complete_upload(etags)
    uri = URI("#{CREDENTIALS["base_uri"]}/ingestion/v1/contributions/#{@contribution_id}")
    payload = {
      id: @contribution_id,
      etags: etags
    }

    client = RequestClient.new(payload, uri, @token)
    client.put
  end
end
