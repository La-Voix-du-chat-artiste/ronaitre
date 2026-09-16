module SmsGateway
  class Result
    attr_reader :ok, :error

    def initialize(ok:, error: nil)
      @ok = ok
      @error = error
    end

    def success?
      @ok
    end
  end

  class Base
    def send!(phone, body)
      raise NotImplementedError
    end
  end

  # Technical stub — logs instead of sending. Swap for a real provider adapter
  # (Vonage/Twilio/Brevo) without touching callers.
  class StubAdapter < Base
    MAX_LENGTH = 320

    def send!(phone, body)
      return Result.new(ok: false, error: "no_phone") if phone.blank?
      return Result.new(ok: false, error: "too_long") if body.length > MAX_LENGTH

      Rails.logger.info("[sms-stub] to=#{phone} body=#{body.inspect}")
      Result.new(ok: true)
    end
  end

  def self.adapter
    @adapter ||= StubAdapter.new
  end

  def self.adapter=(adapter)
    @adapter = adapter
  end

  def self.send!(phone, body)
    adapter.send!(phone, body)
  end
end
