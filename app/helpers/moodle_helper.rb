module MoodleHelper
  
 
  def get_assignments(user_id,aspect_id)
    get_data(user_id,aspect_id,"assignment")
  end
  
  def get_quizzes(user_id,aspect_id)
    get_data(user_id,aspect_id,"quiz")
  end

  private
  def get_data(user_id,aspect_id,request_type)    
    require 'hpricot'
    require 'open-uri'
    
    url = "http://moodle.lmnop.in/" 
    path = "mod/" + request_type + "/index.php?id="
    assignments = []
    doc = Hpricot(open(url + path + user_id))
    (doc/ "#content/table/tr").each do |tablerow|
         temprow = []
        (tablerow/"td").each do |tabledata|
           temprow.push(tabledata.inner_html)
        end
        assignments.push(temprow)
     end
     assignments
  end
end