class RequestClient

  def initialize(payload, uri, token)
    @body = JSON.dump(payload)
    @uri = uri
    @token = token

    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get
    request = Net::HTTP::Get.new(@uri)
    process_request_and_return_response(request)
  end

  def post
    request = Net::HTTP::Post.new(@uri)
    process_request_and_return_response(request)
  end

  def put
    request = Net::HTTP::Put.new(@uri)
    process_request_and_return_response(request)
  end

  private

  def process_request_and_return_response(request)
    request = add_auth_header(request)
    request.body = @body
    @http.request(request)
  end

  def add_auth_header(request)
    request.add_field "Authorization", "Token token=#{@token}"
    request.add_field "Content-Type", "application/json"
    request.add_field "Api-Key", CREDENTIALS["client_id"]
    request
  end
end
