#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class DocumentsController < ApplicationController
  before_filter :authenticate_user!, :except => :show

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
    @post_type = :documents
    @person = Person.find_by_guid(params[:person_id])

    if @person
      @contact = current_user.contact_for(@person)

      if @contact
        @contacts_of_contact = @contact.contacts
        @contacts_of_contact_count = @contact.contacts.count
      else
        @contact = Contact.new
      end

      @posts = current_user.documents_from(@person)

      respond_to do |format|
        format.all { render 'people/show' }
        format.json{ render_for_api :backbone, :json => @posts, :root => :documents }
      end

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
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
        legacy_create      
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
    params.require(:document).permit(:public, :text, :pending, :user_file, :document_url, :aspect_ids)
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
      # create tempora##l file
      file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
      # put data into this file from raw post request
      file.print request.raw_post.force_encoding('BINARY')

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
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

    if @document.save
      aspects = current_user.aspects_from_ids(params[:document][:aspect_ids])

      unless @document.pending
        current_user.add_to_streams(@document, aspects)
        current_user.dispatch_post(@document, :to => params[:document][:aspect_ids])
      end

      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "data" => @document}.to_json )}
        format.html{ render(:layout => false , :json => {"success" => true, "data" => @document}.to_json )}
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
end
