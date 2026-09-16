require "test_helper"

class ChatbotSafetyTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = User.create!(email_address: "chat@example.com", password: "motdepasse1")
    sign_in_as(@user)
  end

  test "normal message gets a supportive reply from stub provider" do
    post chat_path, params: { chat_message: { content: "J'ai eu une envie forte ce soir, j'ai résisté." } }

    assert_redirected_to chat_path
    thread = ChatThread.last
    assert_equal 2, thread.chat_messages.count
    assert_equal "assistant", thread.chat_messages.last.role
    assert_not_equal Chatbot::CRISIS_ANSWER, thread.chat_messages.last.content
  end

  test "crisis keyword surfaces the crisis answer, not the provider" do
    post chat_path, params: { chat_message: { content: "Parfois je pense au suicide." } }

    assert_redirected_to chat_path
    thread = ChatThread.last
    assert_equal Chatbot::CRISIS_ANSWER, thread.chat_messages.last.content
  end

  test "chat page is rate limited" do
    30.times { |i| post chat_path, params: { chat_message: { content: "Message #{i}" } } }

    post chat_path, params: { chat_message: { content: "encore un" } }
    assert_redirected_to chat_path
    assert_match "pause", flash[:alert].to_s
  end

  test "history is deletable" do
    ChatThread.current_for(@user).chat_messages.create!(role: "user", content: "test")

    delete chat_history_path

    assert_redirected_to chat_path
    assert_equal 0, ChatThread.current_for(@user).chat_messages.count
  end

  test "crisis detector" do
    assert Chatbot.crisis?("je veux en finir")
    assert Chatbot.crisis?("SUICIDE")
    assert_not Chatbot.crisis?("j'ai eu une belle journée")
  end
end
