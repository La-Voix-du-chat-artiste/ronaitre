class FieldComponent < ViewComponent::Base
  attr_reader :label, :hint, :error, :for_attr, :html

  def initialize(label:, for_attr: nil, hint: nil, error: nil, html: {})
    @label = label
    @for_attr = for_attr
    @hint = hint
    @error = error
    @html = html
  end

  def call
    safe_join([
      tag.label(label, for: for_attr, class: "mb-1.5 block text-sm font-medium text-foreground"),
      content,
      error && tag.p(error, id: describedby_id, class: "mt-1.5 text-sm text-destructive", role: "alert"),
      !error && hint && tag.p(hint, id: describedby_id, class: "mt-1.5 text-sm text-muted-foreground")
    ].compact)
  end

  def describedby_id
    @describedby_id ||= "#{for_attr}-hint" if for_attr
  end
end
