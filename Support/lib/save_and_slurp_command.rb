require "pickler"

class SaveAndSlurpCommand
  attr_reader :results, :pickler
  
  def initialize(file_path, project_path, document)
    @pickler = Pickler.new(project_path)
  end
  
  def save(file_path)
    @results = {}
    
    feature = @pickler.feature(file_path)
    
    if feature.upload
      # TODO - :created vs :updated
      @results[:created] ||= 0
      @results[:created] += 1
    else
      @results[:errors] ||= 0
      @results[:errors] += 1
    end

  end
  
  #def stories
  #  story_parser.stories
  #end
  
  def tooltip_output
    output = "#{@results[:created] || 0} created. #{@results[:updated] || 0} updated."
    output += " #{@results[:errors]}  errors." if @results[:errors]
    output
  end
end

if __FILE__ == $PROGRAM_NAME
  command = SaveAndSlurpCommand.new(ENV['TM_FILENAME'], ENV['TM_PROJECT_DIRECTORY'], STDIN.read)
  command.save(ENV['TM_FILENAME'])
  print command.tooltip_output
end