class MessagesController < ApplicationController
  layout "app"

  def create
    @conversation = Conversation.find_for_user!(params[:conversation_id], Current.user)
    return head :forbidden unless @conversation.membership.messaging_allowed?

    @message = @conversation.messages.new(sender: Current.user, body: params.dig(:message, :body), channel: "site")

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      redirect_to conversation_path(@conversation), alert: t("messages.invalid")
    end
  end
end
