#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/ui.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate.rb'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/tm_ctags.rb'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/backtrack.rb'

# if current word is in a quoted string, returns full quoted string (w/out the quotes)
def current_word
  return nil unless ENV['TM_CURRENT_WORD']
  string_regex = /(.*?)['"]/
  string_start = ENV['TM_CURRENT_LINE'][0..(ENV['TM_LINE_INDEX'].to_i - 1)].reverse.match(string_regex)
  string_start = string_start[1].reverse if string_start
  string_end = ENV['TM_CURRENT_LINE'][ENV['TM_LINE_INDEX'].to_i..-1].match(string_regex)
  string_end = string_end[1] if string_end
  word = "#{string_start}#{string_end}" if string_start && string_end
  word = ENV['TM_CURRENT_WORD'] unless word
  word
end

# supporting old var for now
ENV['TM_CTAGS_EXT_LIB'] ||= ENV['TM_CTAGS_EXTRA_LIB']

unless ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_CTAGS_EXT_LIB']
  TextMate.exit_show_tool_tip "You must be working with a project or using TM_CTAGS_EXT_LIB to use TM Ctags."
  exit
end

tag_files = []

[ ENV['TM_PROJECT_DIRECTORY'], ENV['TM_CTAGS_EXT_LIB'] ].each do |dir|
  if dir && File.exists?( file = File.join( dir, ".tmtags" ) )
    tag_files << file
  end
end

if tag_files.length == 0
  TextMate.exit_show_tool_tip "You need to Update Tags for this project first. (⌥⌘P)"
  exit
end

tag_files.uniq!

RESULT_LIMIT = ENV['TM_CTAGS_RESULT_LIMIT'] || 300

action = ARGV[0]
nib_title = "Jump to Tag…"
method = :goto

case action
when /complete/
  word = current_word || TextMate::exit_discard
  regex = /^#{Regexp.escape(word)}/i
  nib_title = "Completions"
  method = :build_snippet
when 'find'
  word = current_word || TextMate::exit_discard
  regex = /^#{Regexp.escape(word)}[^\w]/
when 'goto'
  word = TextMate::UI.request_string(:title => "Jump to Tag…", :prompt => "Tag")
  exit if word == nil
  regex = /^#{Regexp.escape(word)}/i
else
  exit
end

hits = []

index = 1

tag_files.each do |f|
  tags = File.read( f ).grep( regex )

  tags.each do |line|
    hit = TM_Ctags::parse( line )
    hit['signature'] = word unless hit['signature'].include?(word) # signature not including multiple words
    hit['f'] = File.dirname( f );
    hits << hit
    index += 1
    break if index > RESULT_LIMIT;
  end
end

hits = hits.sort_by { |h| h['file'] }.each_with_index {|h, i| h['index'] = i }

TextMate.exit_show_tool_tip "'#{word}' not found." if hits.length == 0

TM_Ctags::Backtrack.push

# Complete is done here if dialog 2 completion stuff is used
if action == 'complete2'
  TextMate::exit_insert_snippet( hits[0]['name'] + hits[0]['insert'] ) if hits.length < 2
  TextMate::UI.complete(hits, :extra_chars => '_')
  exit
end

# one hit triggers an action
if hits.length < 2
  TM_Ctags::act_on( hits[0], action )
  exit
end

# Multiple hits requires a dialog box
result = %x{ "$DIALOG" -mc -p '#{{'hits' => hits, 'title' => nib_title}.to_plist.gsub("'", '"')}' "TM_Ctags.nib" | pl }

result = OSX::PropertyList.load(result)

if result['result']
  
  hit = result['result']['returnArgument'][0]
  TM_Ctags::act_on( hit, action )
  
else
  TextMate::exit_discard
end