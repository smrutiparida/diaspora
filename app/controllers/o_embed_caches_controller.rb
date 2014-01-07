class CoursesController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :show, :new]
  respond_to :html, :json, :js

  def new
    @modules = Content.where(:aspect_id => params[:a_id])      
    respond_to do |format|
      format.html
    end
  end

  def create
    @cache = OEmbedCache.new
    @cache.url = params[:o_embed_cache][:url]
    @cache.data = params[:o_embed_cache][:data]
  	if @cache.save!
      Rails.logger.info(@cache.to_json)
      respond_to do |format|
        format.js
      end
    end
  end
end  