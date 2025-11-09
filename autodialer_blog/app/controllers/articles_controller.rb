require 'net/http'
require 'json'

class ArticlesController < ApplicationController

    helper :application
  
  def index
    # Blog listing page
    @articles = Article.order(created_at: :desc)
  end
  
  def show
    # Individual article page
    @article = Article.find_by(slug: params[:id]) || Article.find(params[:id])
  end
  
  def new
    # Admin page to generate articles
  end
  
  def generate
    # Generate articles using AI
    titles_text = params[:titles]
    
    if titles_text.blank?
      redirect_to new_article_path, alert: "Please enter some article titles"
      return
    end
    
    # Parse titles (one per line)
    titles = titles_text.split("\n").map(&:strip).reject(&:blank?)
    
    if titles.empty?
      redirect_to new_article_path, alert: "No valid titles found"
      return
    end
    
    # Limit to 10 articles as per assignment
    titles = titles.first(10)
    
    generated_count = 0
    
    titles.each do |title|
      begin
        # Generate article content
        content = generate_article_with_deepseek(title)
        
        # Generate image
        image_url = generate_image_for_article(title)
        
        # Create slug from title
        slug = title.parameterize
        
        # Save to database
        Article.create!(
          title: title,
          content: content,
          slug: slug,
          image_url: image_url,
          category: 'Programming'
        )
        
        generated_count += 1
        sleep(2)  # Small delay to respect rate limits
        
      rescue => e
        Rails.logger.error "Failed to generate article '#{title}': #{e.message}"
        # Continue with next article
      end
    end
    
    # redirect_to articles_path, notice: "Generated  articles successfully!"
    redirect_to articles_path, notice: "Your article will be generated#{generated_count}, please check 'View All Articles'."
  end
  
  def ai_prompt
    # Handle natural language prompt for article generation
    prompt = params[:prompt]
    
    if prompt.blank?
      redirect_to new_article_path, alert: "Please enter a prompt"
      return
    end
    
    # Simple parsing - look for article topic
    # Example: "generate article about Python web scraping"
    topic = prompt.gsub(/generate article about|create article on|write about/i, '').strip
    
    if topic.present?
      begin
        content = generate_article_with_deepseek(topic)
        image_url = generate_image_for_article(topic)
        
        Article.create!(
          title: topic.titleize,
          content: content,
          slug: topic.parameterize,
          image_url: image_url,
          category: 'Programming'
        )
        
        redirect_to articles_path, notice: "Article generated: #{topic}"
        # redirect_to articles_path, notice: "Your article will be generated, please check 'View All Articles'."
      rescue => e
        redirect_to new_article_path, alert: "Error generating article: #{e.message}"
      end
    else
      redirect_to new_article_path, alert: "Couldn't understand the prompt. Try: 'generate article about Python'"
    end
  end
  
  private
  
  def generate_article_with_deepseek(title)
    # DeepSeek API configuration
    api_key = ENV['DEEPSEEK_API_KEY']
    
    # if api_key.blank?
    #   return "# #{title}\n\nDeepSeek API key not configured. Please add DEEPSEEK_API_KEY to .env file.\n\nThis is a placeholder article."
    # end
    
    # Prepare API request
    uri = URI('https://openrouter.ai/api/v1/chat/completions')
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    
    # Craft the prompt
    prompt = <<~PROMPT
      Write a comprehensive programming article about: #{title}
      
      Requirements:
      - 800-1000 words
      - Include practical code examples
      - Explain concepts clearly for intermediate developers
      - Write in plain text, do NOT use Markdown, headings (# or ##), or code blocks (```).
      - Add sections with headings
      - Use markdown formatting
      - Include best practices and tips
      - Add a conclusion
      
      Write the complete article now:
    PROMPT
    
    request.body = {
      model: 'deepseek/deepseek-chat-v3.1:free',
      messages: [
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 2000
    }.to_json
    
    # Make API call
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      result = JSON.parse(response.body)
      content = result.dig('choices', 0, 'message', 'content')
      return content || "Error: No content generated"
    else
      Rails.logger.error "DeepSeek API error: #{response.code} - #{response.body}"
      return "# #{title}\n\nError generating content. API response: #{response.code}"
    end
    
  rescue => e
    Rails.logger.error "DeepSeek API exception: #{e.message}"
    return "# #{title}\n\nError: #{e.message}"
  end
  
  def generate_image_for_article(title)
    # Option 1: Pollinations.ai (Free, no API key needed)
    # Clean up title for URL
    prompt = title.gsub(/[^a-zA-Z0-9\s]/, '').gsub(/\s+/, '+')
    "https://image.pollinations.ai/prompt/#{prompt}+programming+code+tutorial?width=800&height=400&nologo=true"

  end
  
  def generate_with_huggingface(prompt)
    # Alternative: Use Hugging Face Stable Diffusion
    api_key = ENV['HUGGINGFACE_API_KEY']
    return nil if api_key.blank?
    
    uri = URI('https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1')
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    
    request.body = {
      inputs: "#{prompt} programming illustration, clean design, tech art"
    }.to_json
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      # Save image and return URL (simplified for demo)
      return "data:image/png;base64,#{Base64.strict_encode64(response.body)}"
    else
      return nil
    end
  rescue => e
    Rails.logger.error "Image generation error: #{e.message}"
    nil
  end
end