Rails.application.routes.draw do
  # Root - Main dashboard
  root "home#index"
  
  # Articles routes (Blog)
  resources :articles, only: [:index, :show, :new] do
    collection do
      post :generate      # POST /articles/generate
      post :ai_prompt     # POST /articles/ai_prompt
    end
  end
  
  # Calls routes (Autodialer)
  resources :calls, only: [:index, :new, :create] do
    collection do
      post :batch_upload    # POST /calls/batch_upload
      post :start_calling   # POST /calls/start_calling
      post :ai_prompt       # POST /calls/ai_prompt
    end
  end
  
  # Twilio webhook
  post 'twilio/status', to: 'calls#twilio_status'

  get 'twiml/voice', to: 'calls#twiml_voice'
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end