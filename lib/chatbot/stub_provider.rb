module Chatbot
  class StubProvider
    REPLIES = [
      "Merci de me raconter cela. Comment vous sentez-vous à ce moment précis ?",
      "Je vous entends. Ces journées-là ne définissent pas votre parcours — quel a été votre plus petit pas aujourd'hui ?",
      "C'est un moment difficile, et le fait d'en parler compte déjà. Votre compteur, lui, continue de tourner.",
      "Souhaitez-vous qu'on regarde ensemble ce qui a précédé cette envie ? Comprendre les déclencheurs aide à s'en éloigner.",
      "Bravo pour ce que vous portez depuis le début. De quoi avez-vous besoin maintenant : réconfort, distraction, ou plan pour la soirée ?"
    ].freeze

    def reply(history)
      last_user = history.reverse.find { |m| m[:role] == "user" }
      return "" if last_user.nil?

      REPLIES[last_user[:content].length % REPLIES.length]
    end
  end

  class Client
    def initialize(provider: Chatbot.provider)
      @provider = provider
    end

    def reply(history)
      @provider.reply(history)
    end
  end

  def self.provider
    @provider ||= StubProvider.new
  end

  def self.provider=(provider)
    @provider = provider
  end
end
