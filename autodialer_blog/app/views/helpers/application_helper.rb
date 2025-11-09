module ApplicationHelper
    
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      with_toc_data: true
    )
    markdown = Redcarpet::Markdown.new(renderer, 
      fenced_code_blocks: true,
      tables: true,
      autolink: true,
      strikethrough: true
    )
    markdown.render(text).html_safe
  end
end
