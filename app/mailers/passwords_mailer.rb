class PasswordsMailer < ApplicationMailer
  default from: email_address_with_name(ENV.fetch("MAILER_FROM", "no-reply@ronaitre.example"), "Ronaitre")

  def reset(user)
    @user = user
    mail subject: "Ronaitre — Réinitialisez votre mot de passe", to: user.email_address
  end
end
