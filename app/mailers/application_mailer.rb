class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "notifications@pmapp.local")
  layout 'mailer'

  helper :application
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
end
