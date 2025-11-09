require 'twilio-ruby'

class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:twilio_status]

  def index
    @calls = PhoneCall.order(created_at: :desc)
    @stats = {
      total: @calls.count,
      completed: @calls.where(status: 'completed').count,
      failed: @calls.where(status: 'failed').count,
      in_progress: @calls.where(status: 'in-progress').count,
      answered: @calls.where(answered: true).count
    }
  end

  def new
    # Form page
  end

  def create
    phone = params[:phone_number]
    if phone.present?
      @call = PhoneCall.create(phone_number: phone, status: 'pending')
      redirect_to calls_path, notice: "Phone number added: #{phone}"
    else
      redirect_to calls_path, alert: "Please enter a phone number"
    end
  end

  def batch_upload
    numbers = []
    
    if params[:numbers_text].present?
      numbers = params[:numbers_text].split(/[\n,]/).map(&:strip).reject(&:blank?)
    elsif params[:numbers_file].present?
      file = params[:numbers_file].read
      numbers = file.split(/[\n,]/).map(&:strip).reject(&:blank?)
    end

    count = 0
    numbers.each do |num|
      PhoneCall.create(phone_number: num, status: 'pending')
      count += 1
    end

    redirect_to calls_path, notice: "Added #{count} phone numbers"
  end

  def start_calling
    pending_calls = PhoneCall.where(status: 'pending')
    
    if pending_calls.empty?
      redirect_to calls_path, alert: "No pending calls to make"
      return
    end

    pending_calls.each do |call|
      make_call(call)
      sleep(1)  # Reduced delay
    end

    redirect_to calls_path, notice: "Started calling #{pending_calls.count} numbers. Check the logs!"
  end

  def ai_prompt
    prompt = params[:prompt]
    
    if prompt.blank?
      redirect_to calls_path, alert: "Please enter a prompt"
      return
    end

    # Extract phone number from natural language
    phone_match = prompt.match(/\+?\d{10,}/)
    
    if phone_match
      phone = phone_match[0]
      call = PhoneCall.create(phone_number: phone, status: 'pending')
      make_call(call)
      redirect_to calls_path, notice: "Calling #{phone}..."
    else
      redirect_to calls_path, alert: "Couldn't find phone number. Try: 'call 18001234567'"
    end
  end

  def twilio_status
    call_sid = params['CallSid']
    status = params['CallStatus']
    duration = params['CallDuration']
    
    call = PhoneCall.find_by(call_sid: call_sid)

    if call
      call.update(
        status: status,
        duration: duration.to_i,
        answered: %w[completed in-progress].include?(status)
      )
    end

    render plain: 'OK'
  end

  private

  def make_call(phone_call)
    # Check if Twilio is configured
    has_twilio = ENV['TWILIO_ACCOUNT_SID'].present? && 
                 ENV['TWILIO_AUTH_TOKEN'].present? &&
                 ENV['TWILIO_PHONE_NUMBER'].present?
    
    verified_number = ENV['TWILIO_VERIFIED_NUMBER']
    is_verified = verified_number.present? && phone_call.phone_number == verified_number
    
    if has_twilio && is_verified
      # Make real Twilio call
      make_real_call(phone_call)
    else
      # Simulate call 
      simulate_call(phone_call)
    end
  end

  def make_real_call(phone_call)
    client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )

    begin
      call = client.calls.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: phone_call.phone_number,
        url: twiml_url,
        status_callback: twilio_status_url,
        status_callback_event: %w[initiated ringing answered completed]
      )

      phone_call.update(
        call_sid: call.sid,
        status: 'initiated'
      )
      
      Rails.logger.info "📞 Real call initiated: #{phone_call.phone_number} - SID: #{call.sid}"

    rescue Twilio::REST::RestError => e
      phone_call.update(
        status: 'failed',
        error_message: e.message
      )
      Rails.logger.error "❌ Call failed: #{e.message}"
    end
  end

  def simulate_call(phone_call)
   
    is_toll_free = phone_call.phone_number.start_with?('1800', '1-800', '+1800')
    
    if is_toll_free
      
      statuses = ['completed', 'completed', 'completed', 'completed', 'failed']
      status = statuses.sample
    else
     
      statuses = ['completed', 'completed', 'completed', 'failed', 'no-answer']
      status = statuses.sample
    end
    
   
    duration = case status
    when 'completed'
      rand(30..120)  
    when 'no-answer'
      rand(15..30)   
    else
      0
    end
    
    phone_call.update(
      call_sid: "SIM#{SecureRandom.hex(16)}",
      status: status,
      duration: duration,
      answered: status == 'completed',
      error_message: status == 'failed' ? "Demo Mode: Simulated call failure" : nil
    )

    Rails.logger.info "🤖 Simulated call: #{phone_call.phone_number} → #{status} (#{duration}s)"
  end

  def twiml_url
    "http://demo.twilio.com/docs/voice.xml"
  end

  def twilio_status_url
    "#{request.base_url}/twilio/status"
  end
end