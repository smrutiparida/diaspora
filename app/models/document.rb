#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Document < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at
    t.add :author
    t.add :size
    t.add :processed_doc, :as  => :name
    t.add lambda { "/assets/facebox/" + processed_doc.slice(processed_doc.rindex('.')+1,processed_doc.length) + ".png" }, :as => :icon
  end

  mount_uploader :unprocessed_doc, UnprocessedDocument

  xml_attr :remote_path
  xml_attr :remote_name

  xml_attr :text
  xml_attr :status_message_guid

  xml_attr :size
  

  belongs_to :status_message, :foreign_key => :status_message_guid, :primary_key => :guid
  validates_associated :status_message
  delegate :author_name, to: :status_message, prefix: true

  validate :ownership_of_status_message

  before_destroy :ensure_user_document
  after_destroy :clear_empty_status_message

  #Not required for documents at this point.
  #after_create do
  #  queue_processing_job if self.author.local?
  #end

  def clear_empty_status_message
    if self.status_message_guid && self.status_message.text_and_documents_blank?
      self.status_message.destroy
    else
      true
    end
  end

  def ownership_of_status_message
    message = StatusMessage.find_by_guid(self.status_message_guid)
    if self.status_message_guid && message
      self.diaspora_handle == message.diaspora_handle
    else
      true
    end
  end

  def self.diaspora_initialize(params = {})
    document = self.new params.to_hash.slice(:text, :pending)
    document.author = params[:author]
    document.public = params[:public] if params[:public]
    document.pending = params[:pending] if params[:pending]
    document.diaspora_handle = document.author.diaspora_handle
    document.processed_doc = params[:user_file].original_filename()
    document.size = params[:user_file].content_length()

    document.random_string = SecureRandom.hex(10)
        
    if params[:user_file]      
      doc_file = params.delete(:user_file)
      document.unprocessed_doc.store! doc_file

    # For documents this makes sense when sharing a content from one library that need to create another document object
    elsif params[:doc_url]
      document.remote_unprocessed_doc_url = params[:doc_url]
      document.unprocessed_doc.store!
    end

    document.update_path

    document
  end

  def processed?
    #processed_doc.path.present?
  end

  def update_path
    unless self.unprocessed_doc.url.match(/^https?:\/\//)
      remote_path = "#{AppConfig.pod_uri.to_s.chomp("/")}#{self.unprocessed_doc.url}"
    else
      remote_path = self.unprocessed_doc.url
    end

    name_start = remote_path.rindex '/'
    self.remote_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def url(name = nil)
    if remote_path
      name = name.to_s + '_' if name
      remote_path + name.to_s + remote_name
    elsif processed?
      #there is no processed doc as of now
      #processed_doc.url(name)
      unprocessed_doc.url(name)
    else
      unprocessed_doc.url(name)
    end
  end

 
  def mutable?
    true
  end

  scope :on_statuses, lambda { |post_guids|
    where(:status_message_guid => post_guids)
  }
end
