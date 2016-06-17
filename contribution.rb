class Contribution
  def initialize(token, id, batch_id)
    @token = token
    @id = id
    @batch_id = batch_id
  end

  def get
    begin
      uri = URI("#{CREDENTIALS['base_uri']}/submission/v1/submission_batches/#{@batch_id}/contributions/#{@id}")
      payload = {}
      client = RequestClient.new(payload, uri, @token)
      response = client.get
      handle_response("get", response)
    rescue Exception => e
      puts "HTTP Request failed (#{e.message})"
      raise "Contribution get failed"
    end
  end

  def update
    begin
      uri = URI("#{CREDENTIALS['base_uri']}/submission/v1/submission_batches/#{@batch_id}/contributions/#{@id}")
      payload = { "contribution" => metadata }
      client = RequestClient.new(payload, uri, @token)
      response = client.put
      handle_response("update", response)
    rescue Exception => e
      puts "HTTP Request failed (#{e.message})"
      raise "Contribution update failed"
    end
  end

  def submit
    begin
      uri = URI("#{CREDENTIALS['base_uri']}/submission/v1/submission_batches/#{@batch_id}/contributions/#{@id}/submit")
      payload = {}
      client = RequestClient.new(payload, uri, @token)
      response = client.put
      handle_response("submit", response)
    rescue Exception => e
      puts "HTTP Request failed (#{e.message})"
      raise "Contribution submit failed"
    end
  end

  private

  def handle_response
    if response.code == "200"
      json_response = JSON.parse(response.body, symbolize_names: true)
      return json_response
    else
      puts "Response HTTP Status Code: #{response.code}"
      puts "Response HTTP Response Body: #{response.body}"
      raise "Contribution #{type} failed"
    end
  end
end
