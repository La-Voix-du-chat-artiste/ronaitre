module ApplicationHelper
  COLOR_CLASSES = {
    "primary" => "bg-primary",
    "salmon" => "bg-salmon",
    "mint" => "bg-mint",
    "periwinkle" => "bg-periwinkle",
    "periwinkle-light" => "bg-periwinkle-light",
    "chart-1" => "bg-chart-1",
    "chart-3" => "bg-chart-3"
  }.freeze

  def track_color_class(color)
    COLOR_CLASSES.fetch(color, "bg-primary")
  end

  def sidebar_link_to(label, path, icon:, active: false)
    classes = [
      "flex items-center gap-3 rounded-lg px-3 py-2 font-medium transition",
      active ? "bg-sidebar-accent text-white" : "text-sidebar-foreground/70 hover:bg-sidebar-accent/60 hover:text-white"
    ].join(" ")
    link_to(path, class: classes) do
      safe_join([ sidebar_icon(icon), label ])
    end
  end

  def sidebar_icon(name)
    paths = {
      "gauge" => "M12 14l4-4M3.34 19a10 10 0 1 1 17.32 0",
      "plus" => "M12 5v14M5 12h14",
      "message" => "M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z",
      "users" => "M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75",
      "heart" => "M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z",
      "settings" => "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33 1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82 1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"
    }
    tag.svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", class: "h-4 w-4 shrink-0", "aria-hidden": true) do
      tag.path(d: paths.fetch(name, "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z"))
    end
  end

  def unread_messages_label
    count = Conversation.involving(Current.user).joins(:messages)
                        .where(messages: { read_at: nil })
                        .where.not(messages: { sender_id: Current.user.id })
                        .count
    count.positive? ? "Messagerie (#{count})" : "Messagerie"
  end

  def counter_time(seconds)
    rest = seconds % 86_400
    format("%02d:%02d:%02d", rest / 3_600, (rest % 3_600) / 60, rest % 60)
  end

  def calendar_weeks(month, track)
    first = month.beginning_of_month.beginning_of_week(:monday)
    last = month.end_of_month.end_of_week(:monday)
    today = Date.current
    consumptions = track.consumption_days_in(month)
    milestones_by_date = track.milestones.where.not(reached_at: nil)
                              .index_by { |m| m.reached_at.in_time_zone.to_date }
    streak_start = track.quit_at.in_time_zone.to_date

    (first..last).map do |date|
      next nil unless date.between?(month, month.end_of_month)

      count = consumptions[date] || 0
      {
        day: date.day,
        slip: count.positive?,
        count: count,
        in_streak: date >= streak_start && !track.closed?,
        today: date == today,
        milestone: milestones_by_date[date]&.label,
        tooltip: count.positive? ? "#{count} consommation(s)" : nil
      }
    end
  end

  def format_duration(seconds)
    days = seconds / 86_400
    rest = seconds % 86_400
    hours = rest / 3_600
    minutes = (rest % 3_600) / 60
    secs = rest % 60
    safe_join([
      tag.span("#{days} ", class: "text-4xl font-extrabold tracking-tight"),
      tag.span(t("time.units.days", count: days), class: "text-lg font-bold text-muted-foreground"),
      tag.span(format("%02d:%02d:%02d", hours, minutes, secs), class: "counter-digits mt-1 block text-2xl text-foreground")
    ])
  end
end
