class SubmissionBatch
  def initialize(token)
    @token = token
  end

  def create(name, type)
    begin
      uri = URI("#{CREDENTIALS['base_uri']}/submission/v1/submission_batches")
      # uri = URI("#{CREDENTIALS['base_uri']}/submission/v1/keywords/getty?keywords=athlete&media_type=image")

      payload = {
        "submission_name" => name,
        "submission_type" => type,
        "save_extracted_metadata" => true
      }

      client = RequestClient.new(payload, uri, @token)
      # client = RequestClient.new(nil, uri, @token)
      response = client.post
      # response = client.get

      if response.code == "201"
        json_response = JSON.parse(response.body, symbolize_names: true)
        return json_response
      else
        puts "Response HTTP Status Code: #{response.code}"
        puts "Response HTTP Response Body: #{response.body}"
        raise "Submission Batch Create failed"
      end
    rescue Exception => e
      puts "HTTP Request failed (#{e.message})"
      raise "Submission Batch Create failed"
    end
  end
end
