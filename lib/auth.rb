class Auth
  def self.token
    begin
      uri = URI('https://api.gettyimages.com/oauth2/token')

      # Create client
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      data = {
        "client_id" => CREDENTIALS["client_id"],
        "client_secret" => CREDENTIALS["client_secret"],
        "username" => CREDENTIALS["esp_username"],
        "password" => CREDENTIALS["esp_password"],
        "grant_type" => "password",
      }

      request = create_request(uri, data)
      response = http.request(request)

      if response.code == '200'
        json_response = JSON.parse(response.body, :symbolize_names => true)
        return json_response[:access_token]
      else
        puts "response HTTP Status Code: #{response.code}"
        puts "response HTTP response Body: #{response.body}"
      end
    rescue Exception => e
      puts "HTTP Request failed (#{e.message})"
    end
  end

  def self.create_request(uri, data)
    request = Net::HTTP::Post.new(uri)
    request.add_field "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"
    request.body = URI.encode_www_form(data)
    return request
  end
end
