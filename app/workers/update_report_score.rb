#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class UpdateReportScore < Base
    sidekiq_options queue: :update_score

    def perform(user, aspects)
      #get all posts, all comments from a certain time and analyze each of them  
      #[asked,answered,resolved,score]
      insertion_array = []    
      aspects.each do |aspect|    
        all_my_students = Hash.new{ |h,k| h[k] = [0,0,0,0] }
        all_reports = Report.where(:aspect_id => aspect.id).all
        user.visible_shareables(Post,  {:by_members_of => aspect.id, :limit => 18446744073709551615}).each do |post|
          if user.id != post.author_id
            post.comments.each do |comment|
              if comment.author_id != user.id
                all_my_students[comment.author_id][1] += 1
                all_my_students[comment.author_id][2] += 1 if comment.is_endorsed
              end
            end
            all_my_students[post.author_id][0] += 1
            all_my_students[post.author_id][3] += post.likes_count + post.comments_count  
          end
        end
        #final_score calculation
        all_my_students.each do |key,value_array|
          value_array[3] += value_array[0] + value_array[1] + value_array[2]
        end    
        all_reports.each do |report|
          if all_my_students.has_key?(report.person_id)
            report.update_attributes({:q_asked => all_my_students[report.person_id][0], :q_answered => all_my_students[report.person_id][1], :q_resolved => all_my_students[report.person_id][2], :q_score=>all_my_students[report.person_id][3]})
            all_my_students.delete(report.person_id)
          else
          end
        end    
        all_my_students.each do |key, value_array|
          insertion_array.push "(" + "'#{[user.name, aspect.id, key, value_array[0], value_array[1], value_array[2], value_array[3]].join(",")}'" + ")"
        end  
      end       
          
      conn = ActiveRecord::Base.connection    
      sql = "INSERT INTO reports (`name`, `aspect_id`, `person_id`, `q_asked`, `q_answered`, `q_resolved`, `q_score`) VALUES #{insertion_array.join(", ")}"
      conn.execute sql
    end
  end
end


  

  