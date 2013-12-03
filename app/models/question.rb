class Question < ActiveRecord::Base
  
  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :backbone do |t|
    t.add :id
    t.add :guid
    t.add :created_at  
    t.add :author    
    t.add :description
    t.add :type
    t.add :correct_answer
    t.add :all_answers
  end

  delegate :author_name, to: :current_user, prefix: true

  before_destroy :ensure_user_assignment
  after_destroy :clear_empty_status_message

  def clear_empty_status_message
    if self.status_message_guid && self.status_message.text_and_photos_and_documents_blank_and_assignments_blank?
      self.status_message.destroy
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
