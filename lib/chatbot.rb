module Chatbot
  CRISIS_KEYWORDS = [
    "suicide", "suicider", "me suicider", "tuer", "tuerai", "me tuer",
    "meurt", "mourir", "mourrai", "en finir", "finir avec la vie",
    "plus envie de vivre", "envie de mourir", "overdose", "surdose", "coma"
  ].freeze

  CRISIS_ANSWER = <<~TEXT.chomp
    Je comprends que vous traversiez un moment très difficile, et je veux que vous sachiez que vous n'êtes pas seul·e.

    S'il vous plaît, contactez maintenant des personnes formées pour vous aider :
    · Le 3114 — numéro national de prévention du suicide (24h/24, 7j/7, gratuit)
    · Le 15 ou le 112 en cas d'urgence vitale
    · Drogues Info Service : 0 800 23 13 13 (gratuit, anonyme, 7 j/7)
    · Alcool Info Service : 0 980 980 930

    Vous méritez d'être entendu·e. Parler à un professionnel peut vraiment faire la différence ce soir.
  TEXT

  def self.crisis?(text)
    normalized = text.to_s.downcase
    CRISIS_KEYWORDS.any? { |word| normalized.include?(word) }
  end
end

module Chatbot
  class << self
    def provider
      @provider ||= StubProvider.new
    end

    def provider=(provider)
      @provider = provider
    end
  end
end
