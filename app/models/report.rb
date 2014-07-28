class Report < ActiveRecord::Base

  def update_report_score
    @users = User.joins(person: :profile).where(["profiles.role == ?", "teacher"])
    @users.each do |user|
      #get all posts, all comments from a certain time and analyze each of them  
      #[asked,answered,resolved,score,name]
      insertion_array = []    
      Rails.logger.info(user.aspects.to_json)
      user.aspects.each do |aspect|    
        Rails.logger.info(aspect)
        all_my_students = Hash.new{ |h,k| h[k] = [0,0,0,0] }
        all_reports = Report.where(:aspect_id => aspect.id).all
        user.visible_shareables(Post,  {:by_members_of => aspect.id, :limit => 18446744073709551615}).each do |post|
          if user.id != post.author_id
            post.comments.each do |comment|
              if comment.author_id != user.id
                all_my_students[comment.author_id][1] += 1
                all_my_students[comment.author_id][2] += 1 if comment.is_endorsed
                all_my_students[comment.author_id][4] = comment.author_name
              end
            end
            all_my_students[post.author_id][0] += 1
            all_my_students[post.author_id][3] += post.likes_count + post.comments_count
            all_my_students[post.author_id][4] = post.author_name
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
          insertion_array.push "(" + [ "'" + value_array[4] + "'", aspect.id, key, value_array[0], value_array[1], value_array[2], value_array[3], "'" + Time.now.to_s + "'", "'" + Time.now.to_s + "'"].join(",") + ")"
        end  
      end       
    
      if insertion_array.length > 0
        conn = ActiveRecord::Base.connection    
        sql = "INSERT INTO reports (`name`, `aspect_id`, `person_id`, `q_asked`, `q_answered`, `q_resolved`, `q_score`, `created_at`, `updated_at`) VALUES #{insertion_array.join(", ")}"
        conn.execute sql
      end
    end    
  end
end 