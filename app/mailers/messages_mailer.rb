class MessagesMailer < ApplicationMailer
  default from: email_address_with_name(ENV.fetch("MAILER_FROM", "no-reply@ronaitre.example"), "Ronaitre")

  def new_message(message, recipient)
    @message = message
    @sender = message.sender
    @conversation_url = conversation_url(message.conversation)
    mail subject: "Ronaitre — Nouveau message de #{@sender.display_name.presence || 'votre proche'}", to: recipient.email_address
  end
end
