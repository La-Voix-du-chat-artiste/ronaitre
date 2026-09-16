class ConversationsController < ApplicationController
  layout "app"
  before_action :set_conversation, only: :show

  def index
    @conversations = Conversation.involving(Current.user).recent
    ensure_conversations_for_active_grants!
    @conversations = Conversation.involving(Current.user).recent
  end

  def show
    @messages = @conversation.messages.chronological
    @conversation.mark_read_for!(Current.user)
  end

  private

  def set_conversation
    @conversation = Conversation.find_for_user!(params[:id], Current.user)
  end

  def ensure_conversations_for_active_grants!
    Current.user.owned_memberships.active.joins(:grants).where(grants: { can_message: true }).find_each do |membership|
      Conversation.find_or_create_by!(membership: membership, a: membership.owner, b: membership.member)
    end
    Current.user.memberships_involving.active.joins(:grants).where(grants: { can_message: true }).find_each do |membership|
      Conversation.find_or_create_by!(membership: membership, a: membership.owner, b: membership.member)
    end
  end
end
