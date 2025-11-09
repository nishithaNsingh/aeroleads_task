class HomeController < ApplicationController
  def index
    # Get statistics for dashboard
    @article_count = Article.count
    @call_count = PhoneCall.count
    @completed_calls = PhoneCall.where(status: 'completed').count
    
    # Get recent items for preview
    @recent_articles = Article.order(created_at: :desc).limit(3)
    @recent_calls = PhoneCall.order(created_at: :desc).limit(5)
  end
end