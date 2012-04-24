# encoding: UTF-8

module TM_Ctags
  module_function
  
  def parse(line)
    name = line[/^(\w+)/, 1]
    path = line.split(/\t+/)[1]
    type = line.split(/\t+/)[-2]
    line_no = line[ /line:(\d+)/, 1]
    file = File.basename(path) + ":" + line_no
    
    if type =~ /function|method|member/
      args = parse_args( line )
      signature = name + "(" 
      signature << " " + args.join(", ") + " "
      signature << ")"
    else
      args = []
      signature = name
    end
    
    overview = "#{type} #{signature} — #{file}"
    
    hit = {}
    
    hit['name']      = name 
    hit['match']     = name
    hit['signature'] = signature
    hit['file']      = file
    hit['path']      = path
    hit['line']      = line_no
    hit['args']      = args
    hit['type']      = type
    

    hit['overview'] = overview
    hit['display']  = signature
    hit['insert']   = build_snippet( hit )
    
    hit
  end
  
  def parse_args( line )
    sig = line[ %r{/\^\s*(.+?)\$/}, 1]
    raw = sig[/\((.*?)\)/, 1]
    if raw
      raw.delete(" ").split(',')
    else
      []
    end
  end

  def build_snippet( hit )
    has_args = hit['args'].length > 0
    snippet = ""
    snippet << '(' if has_args || hit['type'] =~ /function|member/
    snippet << "#{args_snippet(hit['args'])}" if has_args
    snippet << ')' if has_args || hit['type'] =~ /function|member/
    snippet << '$0'
  end
  
  def args_snippet( args )
    result = ""
    tab_stop = 1
    optional = 0

    args.each_with_index do |arg, i|
      arg.gsub!('$', '\$')
      is_optional = false
      is_last = i + 1 == args.length
      if arg =~ /=/
        result << "${#{tab_stop}:"
        tab_stop += 1
        optional += 1
        is_optional = true
      end
      result << ", " if i > 0
      result << "${#{tab_stop}:#{ arg.gsub( /[}]/, '\}' ) }}"
      tab_stop += 1
    end
    result + '}' * optional
  end
  
  def goto( hit )
    if defined?(ENV['TM_PROJECT_DIRECTORY'])
      path = ENV['TM_PROJECT_DIRECTORY']
    else
      path = hit['f']
    end
    TextMate.go_to :file => File.join(path, hit['path']), :line => hit['line']
  end
  
  def act_on( hit, action )
    if action =~ /complete/
      print hit['name'] + hit['insert']
    else
      goto( hit )
    end
  end
  
end