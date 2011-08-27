#!/usr/bin/env ruby

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate.rb'
require ENV['TM_SUPPORT_PATH'] + '/lib/progress.rb'

def exec_ctags(filter, ctags_bin, args)
  `#{filter}"#{ctags_bin}" #{args.join(' ')}`
  test_directories = Dir.glob('**/test').collect {|d| d.gsub(/test.*/, 'test') }.uniq
  `#{filter}"#{ctags_bin}" --append=yes --recurse #{args.join(' ')} '#{test_directories.join("\' \'")}'` unless test_directories.empty?
end

# supporting old var for now
ENV['TM_CTAGS_EXT_LIB'] ||= ENV['TM_CTAGS_EXTRA_LIB']

dir = ENV['TM_PROJECT_DIRECTORY']

unless dir
  TextMate.exit_show_tool_tip "You must be working with a project or using TM_CTAGS_EXT_LIB to use TM Ctags."
  exit
end


# Required arguments
base_args = [
  "-f .tmtags",
  "--tag-relative=yes",
  "--fields=Kn",
]


if File.exist? "#{ENV['TM_CTAGS_OPTIONS']}"

  args = ["--options='#{ENV['TM_CTAGS_OPTIONS']}'"]

else
  
  args = [
    "--excmd=pattern",
    "--PHP-kinds=+cfi-v",
    "--regex-PHP='/abstract class ([^ ]*)/\1/c/'",
    "--regex-PHP='/interface ([^ ]*)/\1/c/'" ,
    "--regex-PHP='/(public |static |abstract |protected |private )+function ([^ (]*)/\2/f/'",
    "--JavaScript-kinds=+cf",
    "--regex-JavaScript='/(\w+) ?: ?function/\1/f/'",
    "--Ruby-kinds=+f",
    %q(--regex-Ruby='/^[ \t]*(Factory.define)[ \(]+:(.*)\)/\2/factory/'),
    %q(--regex-Ruby='/^[ \t]*(share_should|share_context|share_setup)[ \(]+['\''"](.*)['\''"]/\2/shared_should/'), # add a closing paren for TM parsing -- )
    ]

  filter = ""
  
  includes = ENV['TM_CTAGS_INCLUDES']
  
  if includes
    includes = includes.split(' ').join("' -or -iname '")
    filter = "find . -iname '#{includes}' | "
    args << "-L -"
  else
    args << "-R"
    
    standard_excludes = %w{.git .svn .cvs}

    user_excludes = []
    user_excludes = ENV['TM_CTAGS_EXCLUDES'].split(' ') if ENV['TM_CTAGS_EXCLUDES']

    excludes = (standard_excludes + user_excludes).uniq

    excludes = excludes.map { |excl| "--exclude='#{excl}'" }

    args += excludes
  end
    
end

args += base_args
  
ctags_bin = ENV['TM_BUNDLE_SUPPORT'] + '/bin/ctags'
  
Dir.chdir(dir)

if ENV['TM_TAG_IN_BACKGROUND'] == '1'
  exec_ctags(filter, ctags_bin, args)
else
  TextMate.call_with_progress( :title => "TM Ctags", :message => "Tagging your project…", :indeterminate => true ) do
    exec_ctags(filter, ctags_bin, args)
    puts "All done."
  end
end