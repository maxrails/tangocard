class Tangocard::Response
  attr_reader :parsed_response, :code

  def initialize raw_response
    @parsed_response  = raw_response.parsed_response
    @code             = raw_response.code
  end

  def success?
    #puts "============= SUCCESS STARTS ============"
    #puts safe_response
    #puts "className: #{safe_response.class}"
    #puts "============= SUCCESS ENDS ============"
    (safe_response['status'].downcase if safe_response['status']) == 'active' || false
  end

  def success_code?
    (safe_response['code'].to_i if safe_response['code'].to_i) == 200 || false
  end

  def error_message
    #puts "============= ERROR STARTS ============"
    #puts safe_response
    #puts "============= ERROR ENDS ============"
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
