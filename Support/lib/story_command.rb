require "erb"
require "ostruct"
require "story"
class StoryCommand
  attr_reader :document, :stories
  
  def initialize(document = "")
    @document = document
  end
  
  def render_snippet
    story = if contains_stories?
      fields_from_last_story
    else
      default_fields
    end
    ERB.new(snippet_erb_template, nil, '-').result(story.instance_eval { binding })
  end
  
  def contains_stories?
    # last_story_in_document
    document.match(/^==*/)
  end
  
  def last_story
    stories.last
  end
  
  def stories
    @stories ||= Story.slurp(document)
  end
  
  # The extracted field values from the last_story_in_document
  # See +default_fields+ for a sample of the output
  def fields_from_last_story
    last_story
  end
  
  def default_fields
    OpenStruct.new({ :biz_value => '...', :role => 'role', :feature => 'feature', :labels => 'comma,separated,labels' })
  end
  
  def snippet_erb_template
    <<-EOS.gsub(/^    /, '')
    name
    	${1:Name of story}
    description
    	In order to ${2:<%= biz_value %>}
    	As a ${3:<%= role %>}
    	I want ${4:<%= feature %>}

    	Acceptance:
    	* ${10:do the thing
    	* don't forget the other thing}
    labels
    	${20:<%= labels %>}
    ===============
    EOS
  end
end

if $0 == __FILE__
  
  print StoryCommand.new(STDIN.read).render_snippet
end