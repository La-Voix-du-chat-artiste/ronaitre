class ChatController < ApplicationController
  layout "app"

  rate_limit to: 30, within: 1.hour, only: :say, with: -> { redirect_to chat_path, alert: t("chat.rate_limited") }

  def show
    @thread = ChatThread.current_for(Current.user)
    @messages = @thread.chat_messages.chronological
  end

  def say
    @thread = ChatThread.current_for(Current.user)
    content = params.dig(:chat_message, :content).to_s.strip
    return redirect_to chat_path, alert: t("chat.empty") if content.blank?

    user_message = @thread.chat_messages.create!(role: "user", content: content[0, 4000])
    assistant_content = crisis_reply(content)
    assistant_message = @thread.chat_messages.create!(role: "assistant", content: assistant_content)

    streams = [
      turbo_stream.append("chat-messages", partial: "chat/message", locals: { message: user_message }),
      turbo_stream.append("chat-messages", partial: "chat/message", locals: { message: assistant_message })
    ]
    streams << turbo_stream.replace("crisis-encart", partial: "chat/crisis_encart") if Chatbot.crisis?(content)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: streams }
      format.html { redirect_to chat_path }
    end
  end

  def destroy_history
    ChatThread.current_for(Current.user).chat_messages.destroy_all
    redirect_to chat_path, notice: t("chat.history_deleted")
  end

  private

  def crisis_reply(content)
    return Chatbot::CRISIS_ANSWER if Chatbot.crisis?(content)

    history = @thread.chat_messages.chronological.last(10).map { |m| { role: m.role, content: m.content } }
    Chatbot::Client.new.reply(history)
  end
end
