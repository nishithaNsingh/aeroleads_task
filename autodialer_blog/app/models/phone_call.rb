class PhoneCall < ApplicationRecord
  # Validations
  validates :phone_number, presence: true
  
  # Scopes for easy querying
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :answered_calls, -> { where(answered: true) }
  
  # Status can be: pending, initiated, ringing, in-progress, completed, failed, busy, no-answer
  
  def status_color
    case status
    when 'completed'
      '#28a745'  # green
    when 'failed', 'busy', 'no-answer'
      '#dc3545'  # red
    when 'in-progress', 'ringing', 'initiated'
      '#007bff'  # blue
    when 'pending'
      '#6c757d'  # gray
    else
      '#ffc107'  # yellow
    end
  end
  
  def status_label
    # User-friendly status labels
    case status
    when 'completed'
      '✅ Completed'
    when 'failed'
      '❌ Failed'
    when 'busy'
      '📵 Busy'
    when 'no-answer'
      '🔇 No Answer'
    when 'in-progress'
      '📞 In Progress'
    when 'ringing'
      '📳 Ringing'
    when 'initiated'
      '⏳ Initiated'
    when 'pending'
      '⏸️ Pending'
    else
      status.titleize
    end
  end
  
  def formatted_duration
    return 'N/A' unless duration && duration > 0
    
    minutes = duration / 60
    seconds = duration % 60
    
    if minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end
  
  def is_simulated?
    # Check if this was a simulated call
    call_sid.present? && call_sid.start_with?('SIM')
  end
  
  def call_type
    is_simulated? ? '🤖 Simulated' : '📞 Real'
  end
end