class FeedbackMailer < ApplicationMailer
  default from: email_address_with_name(ENV.fetch("MAILER_FROM", "no-reply@ronaitre.example"), "Ronaitre")

  def notification(feedback)
    @feedback = feedback
    mail(
      to: "contact@ronaitre.example",
      subject: "[Ronaitre] Nouvel avis — #{@feedback.kind}"
    )
  end
end
