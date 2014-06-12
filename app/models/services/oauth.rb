class Services::Oauth < Service
  include Rails.application.routes.url_helpers
  include MarkdownifyHelper

  def provider
    "oauth"
  end
end
