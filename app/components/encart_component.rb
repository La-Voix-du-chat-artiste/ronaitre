class EncartComponent < ViewComponent::Base
  VARIANTS = {
    help: "border-primary/30 bg-primary/5",
    reassurance: "border-border bg-muted"
  }.freeze

  attr_reader :variant, :html

  def initialize(variant: :reassurance, html: {})
    @variant = variant
    @html = html
  end

  def call
    merged = html.merge(class: "rounded-lg border p-4 text-sm #{VARIANTS.fetch(variant)} #{html[:class]}")
    tag.div(**merged) { content }
  end
end
