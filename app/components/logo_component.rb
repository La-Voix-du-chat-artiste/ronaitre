class LogoComponent < ViewComponent::Base
  attr_reader :wordmark, :dark, :href

  def initialize(wordmark: true, dark: false, href: "/")
    @wordmark = wordmark
    @dark = dark
    @href = href
  end

  def call
    body = safe_join([ logomark, wordmark ? tag.span("Ronaitre", class: "text-lg font-extrabold tracking-tight #{dark ? "text-white" : "text-foreground"}") : nil ])
    href ? link_to(body, href, class: "inline-flex items-center gap-2.5", "aria-label": "Ronaitre") : body
  end

  private

  def logomark
    tag.svg(
      viewBox: "0 0 48 48",
      class: "h-8 w-8",
      "aria-hidden": true
    ) do
      safe_join([
        tag.path(d: "M9 9 L24 39", stroke: "#45BFAE", "stroke-width": 9, "stroke-linecap": "round", fill: "none"),
        tag.path(d: "M24 39 L39 9", stroke: "#128F7E", "stroke-width": 9, "stroke-linecap": "round", fill: "none")
      ])
    end
  end
end
