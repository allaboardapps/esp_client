class SubmissionBatch
  def initialize(token)
    @token = token
  end

  def create(name, type)
    begin
      uri = URI("#{CREDENTIALS['base_uri']}/submissions/v1/submission_batches")

      payload = {
        "submission_name" => name,
        "submission_type" => type,
        "save_extracted_metadata", => true
      }

      client = RequestClient.new(payload, uri, @token)
      response = client.post

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
