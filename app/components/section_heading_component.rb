class SectionHeadingComponent < ViewComponent::Base
  attr_reader :eyebrow, :title, :subtitle, :align, :dark

  def initialize(eyebrow: nil, title:, subtitle: nil, align: :center, dark: false)
    @eyebrow = eyebrow
    @title = title
    @subtitle = subtitle
    @align = align
    @dark = dark
  end

  def call
    tag.div(class: alignment) do
      safe_join([
        eyebrow && tag.p(eyebrow, class: "mb-2 text-sm font-bold tracking-widest uppercase #{dark ? "text-white/70" : "text-primary"}"),
        tag.h2(title, class: "text-3xl font-extrabold tracking-tight sm:text-4xl #{dark ? "text-white" : "text-foreground"}"),
        subtitle && tag.p(subtitle, class: "mx-auto mt-4 max-w-2xl text-lg #{dark ? "text-white/85" : "text-muted-foreground"}")
      ].compact)
    end
  end

  private

  def alignment
    align == :center ? "text-center" : "text-left"
  end
end
