#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ProvidersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html

  def create
  	@consumer_key = 'lmnop-sandbox'
    @consumer_secret = 'lmnop123'

  	# Initialize TP object with OAuth creds and post parameters
	provider = IMS::LTI::ToolProvider.new(@consumer_key, @consumer_secret, params)
	request = Net::HTTP::Post.new('http://dev.lmnop.in/providers/create')

	# Verify OAuth signature by passing the request object
	if provider.valid_request?(request)
	  Rails.logger.info("valid request")
	else
	  # handle invalid OAuth
	  Rails.logger.info("invalid request")
	end
	redirect_to_origin
  end

  private	
  	
end
