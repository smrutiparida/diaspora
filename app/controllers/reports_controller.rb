#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ReportsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html,
             :js,
             :json

  def show   
    #@data =[['Work',     11],['Eat',      2], ['Commute',  2], ['Watch TV', 2],['Sleep',    7]]
    @data2 = [] #[['Work',     11],['Eat',      2], ['Commute',  2], ['Watch TV', 2],['Sleep',    7]]
     
  
  #data for the aspect id, rank all memebers based on data in aspect_assessments table
  #columns needed -> aspect_id, person_id, person_name. qs_asked, qs_answered, answsers_marked_right
  ##@data_for_score_table = []
  ##@status_assessment_table = StatusAssessment.find(params[:a_id])
  #have resolved_Date and closed_date added to the POST table
  #aspect_id, total_respolved, total_marked_right, total_open, total_posts, total_anonymous
  ##@data_for_open_conversations = []
  ##@data_for_closed_conversations = []
  ##@data_for_anonymous_questions = []
  resolve_info = Hash.new {|h,k| h[k] = 0}
  opened_info = Hash.new {|h,k| h[k] = 0}
  user_anonymity_info = h = Hash.new {|h,k| h[k] = 0}
  if current_user.role == "teacher" or current_user.role == "institute_admin"
    #all_posts = Post.joins(:aspect_visibilities).where(:aspect_visibilities => {:aspect_id => params[:id]})  
    all_posts = current_user.visible_shareables(Post,  {:by_members_of => params[:id], :limit => 50})  
    unless all_posts.nil?
      all_posts.each do |p|
        opened_info[p.created_at.beginning_of_week.strftime("%e-%b")] += 1
        resolve_info[p.updated_at.beginning_of_week.strftime("%e-%b")] += 1 if p.is_post_resolved
        p.user_anonymity ? user_anonymity_info["Anonymous"] += 1 : user_anonymity_info["Public"] += 1  
      end
    end  
    @aspect_id = params[:id]
    report_data = Report.where(:aspect_id => params[:id])
    unless report_data.nil?
      report_data.each { |r| @data2.push([r.name, r.q_asked, r.q_answered, r.q_resolved, r.q_score])}
    end   
  end

  @data = []
  @data3 = []
  @data4 = []
  user_anonymity_info.each { |key,value| @data.push([key, value])}
  opened_info.each { |key,value| @data3.push([key, value])}
  resolve_info.each { |key,value| @data4.push([key, value])}
  #Rails.logger.info(@data.to_json)
  #Rails.logger.info(@data2.to_json)
  #Rails.logger.info(@data3.to_json)
  #Rails.logger.info(@data4.to_json)
  respond_to do |format|
    format.html { render :layout => true, :status => 200 }
  end
  end 

  def download
    report_data = Report.where(:aspect_id => params[:a_id])
    @data = []
    @data.push(['user_email','LMNOP Score'])
    unless report_data.nil?
      #max_score = report_data.maximum(:q_score)
      #my_report = report_data.where(:person_id => aspect.user.person.id).first

      #final_score = 0
      #final_score = (my_report.q_score.to_f / max_score).round(2) if my_report and max_score > 0
      all_persons = Person.where(:id => report_data.map(&:person_id))
      hash_key = all_persons.inject({}) do |hash, person|
      hash[person.id] = person
      hash
    end
      report_data.each do |r|
        @data.push([hash_key[r.person_id].owner.email, r.q_score])
      end
    end  
    new_string = ""
    @data.each { |ele| new_string += ele[0] + ',' + ele[1] + '\n'}
    Rails.logger.info(new_string)
    send_data new_string.force_encoding('binary'), :type=>"application/excel", :disposition=>'attachment', :filename => "#{current_user.username}_#{aspect}_faq.xls"
  end

  def snippet
    reports = Report.where(:aspect_id => params[:id]).order('q_asked DESC').limit(5)
    report_data = []
    reports.each {|report| report_data.push({:name => report.name, :score => report.q_score})}
  respond_to do |format|
      format.json do
        render :json => report_data.to_json
      end
    end
  end
end 