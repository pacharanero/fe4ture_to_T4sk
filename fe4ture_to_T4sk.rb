#!/usr/bin/env ruby
require 'gherkin'
require 'asana'
require 'rubygems'
require 'json'
require 'net/https'

#read the README.md file for information on how to configure

class MarcusHackyGherkinFormatter
  def initialize
    @scenarios = []
    @scenario_countr = 0
  end
  
  def feature(feature)
    @feature_title = feature.keyword + ": " + feature.name
    @feature_comments = feature.comments
    @feature_description = feature.description
  end
  
  def background(background) #regard Background as the 1st element in the @scenarios array - @scenarios[0]
    @scenarios[0] = [background.keyword + background.name, "", ""]
  end
  
  def replay
    #not yet implemented
  end
  
  def step(step)
    @scenarios[@scenario_countr][2] << "\n" + step.keyword + " " + step.name
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
    @scenario_countr += 1
    @scenario_title = scenario.keyword + ": " + scenario.name     #prepends the word "Scenario" to the scenario "name" text
    @scenarios[@scenario_countr] = [ @scenario_title, scenario.description, "" ]
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
    list_of_scenarios = ""
    @scenarios.each { |scenario| list_of_scenarios += scenario[0].to_s }
    feature_task = [@feature_title, "#{@feature_description} \n Number of scenarios: #{@scenario_countr} \n List of scenarios: #{list_of_scenarios} "]
  end

  def compose_scenario_task
    scenario_task = @scenarios
  end
  
end

#specify the .feature file source as 1st command line arg
source_file = ARGV[0]

#gherkin parser passes items of the .feature file to the formatter object as method calls
formatter = MarcusHackyGherkinFormatter.new
parser = Gherkin::Parser::Parser.new(formatter)
path = File.expand_path(source_file)
parser.parse(IO.read(path), path, 0)

class SendToAsana
  
  def initialize
    @api_key = 'your asana API key'
    @workspace_id = 'id of the workspace you want tasks to go to' 
    @assignee = 'who do you want to assign the tasks to?'
    
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
        "projects" => 'id of the project you want tasks to go to'
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

class SendToOpenERP

  #I can't access the XMLRPC interface from out here in the wild, but from within T4's intranet it may be possible.

end

#initialize the sender object
sender = SendToAsana.new

#send the feature title, description etc to asana, and append the total number of scenarios in that feature
sender.send(formatter.compose_feature_task[0].to_s, formatter.compose_feature_task[1].to_s)


#send scenarios to Asana as separate Tasks WITH THE BACKGROUND PREPENDED TO EACH ONE
all_scenarios = formatter.compose_scenario_task
all_scenarios.each do |scenario|
  sender.send(scenario[0], "#{all_scenarios[0][0]}: #{all_scenarios[0][2]} \n #{scenario[2]}" )
end

