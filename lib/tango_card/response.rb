class TangoCard::Response
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
    ( true if safe_response['status'].downcase == 'active' ) || false
  end

  def success_code?
    puts safe_response['code']
    ( true if [ 200, 201 ].include?( safe_response['code'].to_i ) ) || false
  end

  def error_message
    #puts "============= ERROR STARTS ============"
    #puts safe_response
    #puts "============= ERROR ENDS ============"
    safe_response['errors'][0]['message']
  end

  private

  def safe_response
    parsed_response || {}
  end
end
