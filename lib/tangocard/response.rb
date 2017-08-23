class Tangocard::Response
  attr_reader :parsed_response, :code

  def initialize(raw_response)
    puts raw_response
    @parsed_response = raw_response.parsed_response
    @code = raw_response.code
  end

  def success?
    safe_response['status'] || false
  end

  def error_message
    safe_response['errors'][0]['message']
  end

  def denial_message
    safe_response['denial_message']
  end

  def denial_code
    safe_response['denial_code']
  end

  def invalid_inputs
    safe_response['invalid_inputs']
  end

  private

  def safe_response
    parsed_response || {}
  end
end
