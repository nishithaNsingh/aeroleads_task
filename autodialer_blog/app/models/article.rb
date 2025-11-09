class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  
  def generate_slug
    self.slug = title.parameterize
  end
  
  def excerpt(length = 200)
    # Get first 200 characters as excerpt
    plain_text = content.gsub(/[#*`\[\]()_]/, '').strip
    plain_text.truncate(length, separator: ' ')
  end
  
  def reading_time
    # Calculate reading time (avg 200 words per minute)
    word_count = content.split.size
    minutes = (word_count / 200.0).ceil
    "#{minutes} min read"
  end
  
  def formatted_content
    content
  end
end