module I18n
  class LoggingExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        Rails.logger.error "I18n:  #{exception}"
      end
      super
    end
  end
end
I18n.exception_handler = I18n::LoggingExceptionHandler.new