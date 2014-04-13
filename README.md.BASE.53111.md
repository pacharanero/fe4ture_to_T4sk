fe4ture_to_T4sk
===============

turns gherkin features into Asana Tasks for Kanban project management

It is a hack on the Gherkin parser which responds to the same method calls that the Gherkin Formatter object responds to. It then gathers the information together and blurts it into your Asana Task.

usage:
* edit code to add your Asana API key in place of YOUR_ASANA_API_KEY (get key within global settings in your Asana account)
* identify the workspace_id of the workspace you are going to send tasks to and put this in place of WORKSPACE_ID - easiest way to do this is with `curl -u YOUR_ASANA_API_KEY : https://app.asana.com/api/1.0/workspaces`
* identify the project_id of the project you are going to send tasks to, again can do this with curl: `curl -u YOUR_ASANA_API_KEY : https://app.asana.com/api/1.0/workspaces/YOUR_WORKSPACE_ID_FROM_ABOVE/projects`
* invoke the script: `$ ./fe4ture_to_T4sk.rb <filename.feature>`

help:
Asana API docs: http://developer.asana.com/documentation/
Gherkin Parser docs: http://cukes.info/api/gherkin/yardoc/Gherkin.html

todo list:
* need to finish the code that adds the scenarios and steps (the responder methods are there, just haven't quite done the 'collate it into a Task' bit (easy))
* add due dates
* abstract out API_KEY etc into a separate file to .gitignore
* and of course I need to refactor it in Python to keep Python supremacist colleagues happy. Well, less unhappy anyway.