class NotificationsMailer < ApplicationMailer
  default from: email_address_with_name(ENV.fetch("MAILER_FROM", "no-reply@ronaitre.example"), "Ronaitre")

  def milestone(user, track, milestone)
    @track = track
    @milestone = milestone
    @track_url = track_url(track)
    mail subject: "Ronaitre — Étape franchie : #{milestone.label} !", to: user.email_address
  end
end
