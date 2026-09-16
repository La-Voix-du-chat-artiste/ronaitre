class CardComponent < ViewComponent::Base
  attr_reader :html

  def initialize(html: {})
    @html = html
  end

  def call
    merged = html.merge(class: "rounded-lg border border-border bg-card text-card-foreground shadow-sm #{html[:class]}")
    tag.div(**merged) { content }
  end
end
