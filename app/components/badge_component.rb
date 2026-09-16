class BadgeComponent < ViewComponent::Base
  VARIANTS = {
    primary: "bg-primary/10 text-primary",
    secondary: "bg-secondary/20 text-secondary-foreground",
    mint: "bg-mint/20 text-primary",
    muted: "bg-muted text-muted-foreground",
    white: "bg-white/15 text-white",
    destructive: "bg-destructive/10 text-destructive"
  }.freeze

  attr_reader :variant, :html

  def initialize(variant: :primary, html: {})
    @variant = variant
    @html = html
  end

  def call
    merged = html.merge(class: "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-sm font-medium #{VARIANTS.fetch(variant)} #{html[:class]}")
    tag.span(**merged) { content }
  end
end
