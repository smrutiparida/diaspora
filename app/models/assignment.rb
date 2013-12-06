class Assignment < ActiveRecord::Base
  include Diaspora::Federated::Shareable
  include Diaspora::Commentable
  include Diaspora::Shareable

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at
    t.add :submission_date
    t.add :author
    t.add :name
    t.add :description
    t.add :pending    
  end

  xml_attr :text
  xml_attr :name
  xml_attr :status_message_guid

  belongs_to :status_message, :foreign_key => :status_message_guid  , :primary_key => :guid
  validates_associated :status_message
  delegate :author_name, to: :status_message, prefix: true

  validate :ownership_of_status_message

  before_destroy :ensure_user_assignment
  after_destroy :clear_empty_status_message

  def clear_empty_status_message
    if self.status_message_guid && text_and_photos_and_documents_blank_and_assignments_blank_and_quizzes_blank?
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
    assignment = self.new #params.to_hash.slice(:name, :description, :submission_date)
    assignment.name = params[:name]
    assignment.description = params[:description]
    assignment.file_upload = false unless params[:file_upload]
    assignment.author = params[:author]
    assignment.public = params[:public] if params[:public]
    assignment.pending = params[:pending] if params[:pending]
    assignment.diaspora_handle = assignment.author.diaspora_handle
    
    #submission_date is turning out to be null.. need fixing
    #assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y %I:%M:%S %p')
    assignment.submission_date = DateTime.strptime(params[:submission_date],'%d/%m/%Y')
        
    assignment
  end

  scope :on_statuses, lambda { |post_guids|
    where(:status_message_guid => post_guids)
  }
end
