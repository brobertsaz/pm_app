class SendNotificationJob < ApplicationJob
  queue_as :notifications

  sidekiq_options retry: 5, dead: true

  def perform(mailer_class, mailer_method, *args)
    mailer_class.constantize.send(mailer_method, *args).deliver_now
  rescue StandardError => e
    Rails.logger.error("Failed to send notification: #{e.message}")
    raise e
  end
end
