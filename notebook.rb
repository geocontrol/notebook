require 'rubygems'
require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("http://bookleteer.com/api/editEBook")
API_KEY = "d7c6557cbc798f02bf39dd933dbad7e9eddb9ea7"


get '/' do
  erb :form
end

post '/form' do
  # Gets the details from the form and creates the HTML etc for the bookleteer call

  html = ''
  int = Integer(params['pages'])
  for i in (1..int-1)
    #<div style="background-image: url(../images/test-background.gif); height: 100%; width: 100%; background-repeat: repeat"> </div>    
 
    if params['page_background'] == "grid"
      html += '<div style="background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC8AAAAvCAIAAAD8RQT7AAAAvUlEQVRYCe3ZSw6EIBBFUdoV6f73IO4In41xYHxF7EGnBpeB0SoEAsdPtLTW1rq+3f5wytXFtXNrRIcf5UqOUrdaNJoMpc/TlGNezlGwUk8y0q2UFCdys8wLbnDz+kaGmyc0inG/CS3hBjchEJPEDW4MDR8WmiNpZu7fYZ4MfqWU4Qo3IHGDG0MjDOMGNyEQk8QNbgyNMIybkZtE3/001ESjyfdNVJj7auq19Pjv8C3D/WEFNePq9C5uFXpwB//f+Z27XQhFAAAAAElFTkSuQmCC); background-repeat:repeat; height:500px; width:500px;">&nbsp;</div>'
    else
      html += '&nbsp;'
    end
    html += '<div style=\'page-break-after:always\'></div>'
    html = html.encode('UTF-8')
  end
  
  #before returning HTML send this to bookleteer.
  
  # Create a new publication
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri)
#  request = Net::HTTP::Get.new(uri.request_uri)
  request.set_form_data({"key" => API_KEY, "generatePDFs" => "0", "format" => (params['format'])})
#  request.set_form_data({"key" => API_KEY, "generatePDFs" => "0", "html" => html, "title" => (params['title'])})
  response = http.request(request)
  parsed = JSON.parse(response.body)
  puts parsed
  puts parsed["payload"]
  pub_id = parsed["payload"]["id"]
  puts pub_id
  
  # Set some values
  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data({"key" => API_KEY, "id" => pub_id, "title" => (params['title']), "html" => html})
  response = http.request(request)
  parsed = JSON.parse(response.body)
  
  # Generate the PDFs
  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data({"key" => API_KEY, "id" => pub_id, "generatePDFs" => "1"})
  response = http.request(request)
  parsed = JSON.parse(response.body)  
  
  # If the result is 'OK' then should display a page that links to the PDF and a link back to the form?
  if parsed["result"] == "OK"
    return_html = "<p><a href =\"http://bookleteer.com/api/getPublicationPDF?key=" + API_KEY + "&id=" + pub_id.to_s() + "&pageSize=a4\">Download PDF of notebook</a></p><p><a href=\"/\">Another one?</a></p>"
  else
    return_html = "<p>There was a problem: " + parsed["result"]
  end
  
#  puts parsed["result"]
#  debug_message = request.body + response.body
#  return pub_id
  return return_html
end
