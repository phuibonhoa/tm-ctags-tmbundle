require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate.rb'
require 'uri'

module TM_Ctags
 class Backtrack
   FILE = File.join(ENV['TM_BUNDLE_SUPPORT'], 'backtrack.txt')

   class << self
     def textmate_url(path, line_number, column_number)
       options = []
       options << "url=file://#{URI.escape(path)}"
       options << "line=#{line_number}" if line_number
       options << "column=#{column_number}" if column_number
     
       "txmt://open?#{options.join('&')}"
     end
   
     def go
       last_url = pop
       if !last_url.nil? and last_url.strip != ''
         `open "#{last_url}"`
       else
         TextMate.exit_show_tool_tip("No backtrack location")
       end
     end
   
     def pop
       lines = File.readlines(FILE)
       last_position = lines.last
       File.open(FILE, 'w') do |file|
         file.print(lines[0..-2].join(""))
       end
     
       last_position
     end
   
     def push
       File.open(FILE, 'a') do |file|
         file.puts(textmate_url(ENV['TM_FILEPATH'], ENV['TM_LINE_NUMBER'], ENV['TM_LINE_INDEX']))
       end
     end
   end
 end
end