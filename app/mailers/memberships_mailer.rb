class MembershipsMailer < ApplicationMailer
  default from: email_address_with_name(ENV.fetch("MAILER_FROM", "no-reply@ronaitre.example"), "Ronaitre")

  def invitation(membership)
    @membership = membership
    @owner = membership.owner
    @accept_url = invitation_url(membership.invite_token)
    recipient = membership.member&.email_address || membership.invited_email
    mail subject: "Ronaitre — #{@owner.display_name.presence || 'Un proche'} vous invite à suivre sa progression", to: recipient
  end
end
