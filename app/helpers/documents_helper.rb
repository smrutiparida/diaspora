module DocumentsHelper
  API_KEY = "wo753emrs8l2o0vesjaoxti5n3r9cyvi" 
  API_SECRET = "rmu2dklxoz5htmul2gkhpk6j40qrqx0d"
 
  def create_view(document)
    params = doc_upload_params(document)
    params['action'] = "issuu.document.url_upload"
    Rails.logger.info(params.to_json)
    post_issuu(params)
  end
  
  private

  def upload_issuu(params)   
    require "uri"
    require "net/http"
    post_params = {'api_key' => API_KEY, 'action' => "issuu.document.url_upload"}
    post_params['signature'] = generate_signature(params)
    x = Net::HTTP.post_form(URI.parse('http://api.issuu.com/1_0'), post_params)
    Rails.logger.info(x.body)
  end

  def generate_signature(params)
    string_to_sign = "#{API_SECRET}#{params.sort_by {|k| k.to_s }.to_s}"
    Digest::MD5.hexdigest(string_to_sign)
  end
  
  def doc_upload_params(document)
    predefined_params = {'api_key' => API_KEY, 'commentsAllowed' => false, 'downloadable' => false, 'access' => 'private', 'ratingsAllowed' => false, 'format' => 'json'}
    predefined_params['slurpUrl'] = document.remote_path + document.remote_name
    predefined_params['name'] = document.remote_name
    predefined_params['title'] = document.processed_doc
    predefined_params['type'] = 002000 #refers to book. We need to explore what happens when the tpe is posted as report/article/magazine
    #predefined_params['folderIds'] 
    predefined_params
  end
    
end
