#!/usr/bin/env ruby
require 'gherkin'
require 'asana'
require 'rubygems'
require 'json'
require 'net/https'

class MarcusHackyGherkinFormatter
  def initialize
    #nothing needed, included for compatibility with Gherkin gem
  end
  
  def feature(feature)
    @feature_title = feature.keyword + ": " + feature.name
    @feature_comments = feature.comments
    @feature_description = feature.description
  end
  
  def background(background)
    @background_info = background.keyword + ": " + background.name
    #puts @background_info
  end
  
  def replay
    #not yet implemented
  end
  
  def step(step)
    @steps = []
    @steps << step
    @step_info = step.keyword + " " + step.name
    #puts @step_info
  end

  def done
    #not yet implemented
  end 
  
  def eof
    #not yet implemented
  end    

  def examples(examples)
    #not yet implemented
  end

  def scenario(scenario)
    @scenario_title = scenario.keyword + ": " + scenario.name
    @scenario_comments =  scenario.comments
    @scenario_description = scenario.description
  end

  def scenario_outline(scenario_outline)
    puts scenario_outline
  end

  def uri(uri)
    #not yet implemented
  end
  
  def table(rows)
    #not yet implemented
  end
  
  def compose_feature_task
    feature_task = [@feature_title, @feature_description]
  end
  
  def compose_scenario_task
    #puts @scenario_title
    #puts @scenario_comments
    #puts @scenario_description
  end
  
end

#specify the .feature file source
source_file = ARGV[0]

#gherkin parser passes to formatter object
formatter = MarcusHackyGherkinFormatter.new
parser = Gherkin::Parser::Parser.new(formatter)
path = File.expand_path(source_file)
parser.parse(IO.read(path), path, 0)

class SendToAsana
  
  def initialize
    @api_key = 'YOUR_ASANA_API_KEY' #see README.md for tips on how to get this
    @workspace_id = 'WORKSPACE_ID' #see README.md for tips on how to get this
    @assignee = 'ASSIGNEE_EMAIL_HERE' 
    
    # set up HTTPS connection
    @uri = URI.parse("https://app.asana.com/api/1.0/tasks")
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    
    # set up the request
    @header = { "Content-Type" => "application/json" }
  end
  
  def send(task_name, task_notes) #can add other task attributes in future eg due date
    req = Net::HTTP::Post.new(@uri.path, @header)
    req.basic_auth(@api_key, '')
    req.body = {
      "data" => {
        "workspace" => @workspace_id,
        "name" => task_name,
        "notes" => task_notes,
        "assignee" => @assignee,
        "projects" => 'PROJECT_ID_HERE' #change this for the ID of the project you want to push tasks to
      }
    }.to_json()
    
    # issue the request
    res = @http.start { |http| http.request(req) }
    
    # output
    body = JSON.parse(res.body)
    if body['errors'] then
      puts "Server returned an error: #{body['errors'][0]['message']}"
      else puts "Created task with id: #{body['data']['id']}"
    end
  end
  
end

sender = SendToAsana.new
sender.send(formatter.compose_feature_task[0].to_s, formatter.compose_feature_task[1].to_s)
