class ButtonComponent < ViewComponent::Base
  VARIANTS = {
    primary: "bg-secondary text-secondary-foreground hover:brightness-95 shadow-sm",
    inverted: "bg-primary text-primary-foreground hover:bg-primary/90 shadow-sm",
    outline: "border border-white/40 text-white hover:bg-white/10",
    outline_muted: "border border-border text-foreground hover:bg-muted",
    ghost: "text-foreground hover:bg-muted"
  }.freeze

  SIZES = {
    sm: "h-8 px-3 text-sm",
    md: "h-10 px-5 text-sm",
    lg: "h-12 px-7 text-base"
  }.freeze

  attr_reader :variant, :size, :href, :options

  def initialize(variant: :primary, size: :md, href: nil, **options)
    @variant = variant
    @size = size
    @href = href
    @options = options
  end

  def call
    if href
      link_to(href, **options, class: classes) { content }
    else
      button_tag(**options, type: options.fetch(:type, "button"), class: classes) { content }
    end
  end

  private

  def classes
    [
      "inline-flex items-center justify-center gap-2 rounded-lg font-semibold",
      "transition focus-visible:outline-2 focus-visible:outline-ring",
      VARIANTS.fetch(variant),
      SIZES.fetch(size)
    ].join(" ")
  end
end
