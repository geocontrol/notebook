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
    html += '&nbsp;<div style=\'page-break-after:always\'></div>'
    html = html.encode('UTF-8')
  end
  
  #before returning HTML send this to bookleteer.
  
  # Create a new publication
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri)
#  request = Net::HTTP::Get.new(uri.request_uri)
  request.set_form_data({"key" => API_KEY, "generatePDFs" => "0"})
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
  
puts parsed["result"]
#  debug_message = request.body + response.body
#  return pub_id
  return parsed["result"]
end
