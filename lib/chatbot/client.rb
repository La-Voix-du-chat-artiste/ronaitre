module Chatbot
  class Client
    def initialize(provider: Chatbot.provider)
      @provider = provider
    end

    def reply(history)
      @provider.reply(history)
    end
  end
end
