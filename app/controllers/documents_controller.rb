#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class DocumentsController < ApplicationController
  before_filter :authenticate_user!, :except => :show

  API_KEY = "wo753emrs8l2o0vesjaoxti5n3r9cyvi" 
  API_SECRET = "rmu2dklxoz5htmul2gkhpk6j40qrqx0d"
  API_URL = "http://api.issuu.com/1_0"
  respond_to :html, :json

  def show
    @document = if user_signed_in?
      current_user.documents_from(Person.find_by_guid(params[:person_id])).where(id: params[:id]).first
    else
      Document.where(id: params[:id], public: true).first
    end

    raise ActiveRecord::RecordNotFound unless @document
  end

  def index
    #@assignment_active = (params[:tab] == "assignment") ? 1 : 0
    @overlay = params[:overlay] == "1" ? true : false
    @folder = "Miscellaneous"
    if params[:a_id]
      aspect_detail = Aspect.find(params[:a_id]) 
      @folder = aspect_detail.name
    end
            
    @documents = Document.where(:diaspora_handle => current_user.diaspora_handle, :folder => @folder).order(:updated_at)  
    #@folder_list = Document.select(:folder).distinct
    #below logic valid for students. For teachers the logic will be different.
    #if @teacher
    #  @assignments = Assignment.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    #  @quizzes = Quiz.where(:diaspora_handle => current_user.diaspora_handle).order(:updated_at)  
    #else      
    #  opts = {}
    #  if params[:a_id]
    #    opts[:by_members_of] = params[:a_id]
    #  end  
    #  
    #  all_my_posts = current_user.visible_shareables(Post, opts)
    #  all_my_post_guid = all_my_posts.map{|a| a.guid}
      
    #  @assignments = Assignment.where(:status_message_guid => all_my_post_guid)
    #  @quizzes = Quiz.where(:status_message_guid => all_my_post_guid)
    #  @documents += Document.where(:status_message_guid => all_my_post_guid)
    #end
    if !params[:a_id].nil? and @overlay
      @modules = Content.where(:aspect_id => params[:a_id])
    end  
    respond_to do |format|
      @overlay ? format.html { render 'documents/course', :layout => false } : format.html   
      format.json {render :json => {'documents' => @documents}.to_json}
    end
  end


  def create
    rescuing_document_errors do
      if remotipart_submitted?
        @document = current_user.build_post(:document, document_params)
        if @document.save
          respond_to do |format|
            format.json { render :json => {"success" => true, "data" => @document.as_api_response(:backbone)} }
          end
        else
          respond_with @document, :location => documents_path, :error => message
        end
      else
        Rails.logger.info("came here")
        legacy_create    
      end  
    end
  end

  
  def destroy
    document = current_user.documents.where(:id => params[:id]).first

    if document
      current_user.retract(document)

      respond_to do |format|
        format.json{ render :nothing => true, :status => 204 }
        format.html do
          flash[:notice] = I18n.t 'documents.destroy.notice'
          if StatusMessage.find_by_guid(document.status_message_guid)
              respond_with document, :location => post_path(document.status_message)
          else
            respond_with document, :location => person_documents_path(current_user.person)
          end
        end
      end
    else
      respond_with document, :location => person_documents_path(current_user.person)
    end
  end

  def edit
    if @document = current_user.documents.where(:id => params[:id]).first
      respond_with @document
    else
      redirect_to person_documents_path(current_user.person)
    end
  end

  def update
    document = current_user.documents.where(:id => params[:id]).first
    if document
      if current_user.update_post( document, document_params )
        flash.now[:notice] = I18n.t 'documents.update.notice'
        respond_to do |format|
          format.js{ render :json => document, :status => 200 }
        end
      else
        flash.now[:error] = I18n.t 'documents.update.error'
        respond_to do |format|
          format.html{ redirect_to [:edit, document] }
          format.js{ render :status => 403 }
        end
      end
    else
      redirect_to person_documents_path(current_user.person)
    end
  end

  private

  def document_params
    params.require(:document).permit(:public, :text, :pending, :user_file, :document_url, :aspect_ids, :folder)
  end

  def file_handler(params)
    # For XHR file uploads, request.params[:qqfile] will be the path to the temporary file
    # For regular form uploads (such as those made by Opera), request.params[:qqfile] will be an UploadedFile which can be returned unaltered.
    if not request.params[:qqfile].is_a?(String)
      params[:qqfile]
    else
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      #get file content length
      att_content_length = (request.content_length.to_i == 0) ? 0 : request.content_length.to_i
      # create tempora##l file
      file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
      # put data into this file from raw post request
      file.print request.raw_post.force_encoding('BINARY')

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      Tempfile.send(:define_method, "content_length") {return att_content_length}
      Rails.logger.info("inside file handler")
      Rails.logger.info(file.to_json)
      file
    end
  end

  def legacy_create
    if params[:document][:aspect_ids] == "all"
      params[:document][:aspect_ids] = current_user.aspects.collect { |x| x.id }
    elsif params[:document][:aspect_ids].is_a?(Hash)
      params[:document][:aspect_ids] = params[:document][:aspect_ids].values
    end

    params[:document][:user_file] = file_handler(params)
    
    @document = current_user.build_post(:document, params[:document])
    Rails.logger.info("Before saving")
    Rails.logger.info(@document.to_json)
    return_stage = create_view(@document)
    if return_stage['stat'] == 'ok'
      return_stage = get_embed_id(return_stage['_content']['document']['documentId'])
      Rails.logger.info(return_stage['stat'])
      Rails.logger.info(return_stage)
      @document.issuu_id = return_stage['_content']['result']['_content'][0]['documentEmbed']['dataConfigId'] if return_stage['stat'] == 'ok'
    end  
    if @document.save
      aspects = current_user.aspects_from_ids(params[:document][:aspect_ids])

      unless @document.pending
        if @document.public
          current_user.add_to_streams(@document, aspects)
          current_user.dispatch_post(@document, :to => params[:document][:aspect_ids])
        end  
      end

      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "overlay" => params[:overlay], "data" => @document}.to_json )}
        format.html{ render(:layout => false , :json => {"success" => true, "overlay" => params[:overlay], "data" => @document}.to_json )}
      end
    else
      respond_with @document, :location => documents_path, :error => message
    end
  end

  def rescuing_document_errors
    begin
      yield
    rescue TypeError
      message = I18n.t 'documents.create.type_error'
      respond_with @document, :location => documents_path, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'documents.create.integrity_error'
      respond_with @document, :location => documents_path, :error => message

    rescue RuntimeError => e
      message = I18n.t 'documents.create.runtime_error'
      respond_with @document, :location => documents_path, :error => message
      raise e
    end
  end
 
  def get_embed_id(documentId)
    params = {:action => "issuu.document_embeds.list", :apiKey => API_KEY, :documentId => documentId }
    upload_issuu(params,"get") 
  end

  def create_view(document)
    params = doc_upload_params(document)
    params[:action] = "issuu.document.url_upload"
    upload_issuu(params,"post")
  end

  def upload_issuu(params,type)   
    require "uri"
    require "net/http"
    require 'cgi'
    x = nil
    if type == "post"
      x = Net::HTTP.post_form(URI.parse(API_URL), params.merge(:signature => generate_signature(params)))
    else
      params.merge(:signature => generate_signature(params)
      Rails.logger.info("i am here")  
      x = Net::HTTP.get(URI.parse(API_URL), "?".concat(params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')))
    end  
    Rails.logger.info(x.body)
    json = JSON.parse x.body
    return json['rsp']
  end

  def generate_signature(params)
    string_to_sign = "#{API_SECRET}"
    params.sort_by {|k| k.to_s }.each{|k,v| string_to_sign += k.to_s + v.to_s}
    #{API_SECRET}#{params.sort_by {|k| k.to_s }.to_s}"
    Rails.logger.info(string_to_sign)
    Digest::MD5.hexdigest(string_to_sign)
  end
  
  def doc_upload_params(document)
    predefined_params = {:apiKey => API_KEY, :commentsAllowed => false, :downloadable => false, :access => 'private', :ratingsAllowed => false, :format => 'json'}
    predefined_params[:slurpUrl] = document.remote_path + document.remote_name
    predefined_params[:name] = document.remote_name
    predefined_params[:title] = document.processed_doc
    #predefined_params[:type] = "002000" #refers to book. We need to explore what happens when the tpe is posted as report/article/magazine
    #predefined_params['folderIds'] 
    predefined_params
  end
end
