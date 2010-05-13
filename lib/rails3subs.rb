module rails3subs
  def self.included(base)
    base.extend ClassMethods
  end

  def ensure_unique(name)
    begin
      self[name] = yield
    end while self.class.exists?(name => self[name])
  
   module ClassMethods
#
# Gem to search and replace RAILS constants and methods 
# with Rails 3 replacements
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
DEBUG = true
HELP =<<EOS
== rails3-subs
  This command will replace all of the matching patterns in all
  files from this directory and below with the substitution strings 
  found in the foo.txt file.
  
    ruby3_subs [filename].sub

  [filename].sub file format should be a search string followed by 3 colons \':::\' followed by 
  a replacement string. Each search:::replacement should be on it\'s own line. For example:

  This:::That
  Sooner:::Later
  Empty:::Full
  This string has spaces:::And so does this one.

  Other examples:
    rails3-subs -q bar.sub
    rails3-subs --verbose foo.sub

== Usage 
  rails3-subs [options] source_file

  rails3-subs [options] pattern1:::replacement1 pattern2:::replacement2 pattern3:::replacement3
  or
  rails3-subs [options] ]filename.sub

  For help use: rails3-subs -h

== Options
  -h, --help          Displays help message
  -d  --delim=        Set pattern:::substitution record separator (default = ":::")
  -e, --ext=          Followed by a comma separated list of file extensions to substitute 
  -i, --input=        Followed by [filename].sub containing pattern:::substitution list  
  -v, --version       Display the version, then exit
  -q, --quiet         Output as little as possible, overrides verbose
  -V, --verbose       Verbose output
EOS

# states for the command line parser
NONE = 0
DELIMIT = 1
EXTENSIONS = 2
VERBOSE = 3
DONE = 4

STATE_STRS = ["None","Delimit","Extensions","Verbose","Done"]
INTRO =<<EOS
This script will search and replace the following list of deprecated
Rails constants and method calls with their Rails 3 replacements

Original Rails constants and methods                 |  Rails 3 replacements
-----------------------------------------------------------------------------
RAILS_ENV                                            => Rails.env
RAILS_ROOT                                           => Rails.root
RAILS_CACHE                                          => Rails.cache
RAILS_DEFAULT_LOGGER                                 => Rails.logger
filter_parameter_logging                             => config.filter_parameters
AC::Dispatcher.before_dispath                        => ActionDispatch::Callbacks.before
AC::Dispatcher.to_prepare                            => config.to_prepare
AC::Dispatcher                                       => Rails::Application
config.action_controller.consider_all_requests_local => Rails.application.config.consider_all_requests_local
config.action_controller.allow_concurrency           => Rails.application.config.allow_concurrency
benchmark(:level)                                    => benchmark(\"message\", :level => level)
config.view_path                                     => path.apps.views
config.routes_configuration_file                     => paths.config_routes
config.database_configuration_file                   => paths.config.database
config.controller_paths                              => paths.app.controllers
config.log_path                                      => paths.log

Press 'y' to execute replacement, 'n' will abort: 
EOS

SUB_STRS = []
#
# Array of Arrays containing the pattern to search for 
# followed by the string to replace it with
#
RAILS_SUB_STRS= [ ["RAILS_ENV","Rails.env"],
                  ["RAILS_ROOT", "Rails.root"],
                  ["RAILS_CACHE" ,"Rails.cache"],
                  ["RAILS_DEFAULT_LOGGER","Rails.logger"],
                  ["filter_parameter_logging","config.filter_parameters"],
                  ["AC::Dispatcher.before_dispath","ActionDispatch::Callbacks.before"],
                  ["AC::Dispatcher.to_prepare","config.to_prepare"],
                  ["AC::Dispatcher","Rails::Application"],
                              ["config\.action_controller.consider_all_requests_local", "Rails.application.config.consider_all_requests_local"],
                  ["config\.action_controller.allow_concurrency","Rails.application.config.allow_concurrency"],
                  ["benchmark(:level)","benchmark(\"message\", :level => level)"],
                  ["config\.view_path" ,"path.apps.views"],
                  ["config\.routes_configuration_file","paths.config_routes"],
                  ["config\.database_configuration_file","paths.config.database"],
                  ["config\.controller_paths","paths.app.controllers"],
                  ["config\.log_path","paths.log"] 
                ]

CHANGED = []
#
# Extend File class to include the replace method
#
class File
  def replace(pattern, string)
    full_path = File.expand_path path

    if !File.file?(full_path) then
      puts "Not a file!"
      return
    end  

    reopen(full_path, 'r')
    lines = readlines 

    changes = false
    lines.each do |line|
      changes = true if line.gsub!(pattern, string)
    end

    if changes
      reopen(full_path, 'w')
      CHANGED << full_path
      lines.each do |line|
        write(line)
      end
      close
    end
  end
end

module Rails3Subs
  VERSION = '0.0.1'
  $DEBUG=true

  require 'find'  
  
  class SearchAndReplace
    attr_accessor :flist, :sub_strs, :delimiter, :verbose, :version, :state, :infile
    
    def initialize()
      @infile = ""
      @cfgfile = "r3-subs.cfg"
      @state=NONE
      @version = "0.1.0"
      @verbose = false
      @sub_strs = Array::new
      @delimiter = ':::'
      @rootDirectory =IO.readlines("r3-subs.cfg")[1].strip!  
      @includedFileTypes =IO.readlines("r3-subs.cfg")[3].downcase.split(",")  
      @excludedDirectoryNames =IO.readlines("r3-subs.cfg")[5].downcase.split(",")  
      @flist = Array::new
      puts @includedFileTypes      
      process_args
    end  

    def process_args     
      n=1
      ARGV.each do|arg|
        puts "arg = #{arg}"
        if(arg.include?(".sub"))
          @infile = arg
          @state = DONE
        end
        case @state
          if DEBUG then
            puts "Current State = #{STATE_STRS[@state]}")
          end 
          when NONE
            # See if there are command line options  
            if( (arg[0] == '-') || (arg[0,2] == '--') )
              # process options
              case arg
                when '-e'
                  # add extensions to @includedFileTypes
                  @state = EXTENSIONS
                when '-h'
                  # show help
                  puts HELP
                  exit 0
                when '-d'
                  # change record delimiter
                  @state = DELIMIT
                when '-v'
                  # show version and exit              
                  puts "rails3-subs, version #{@version}"
                  exit 0
                when '-V'
                  # turn on verbose output
                  @state = VERBOSE
              end # case arg
            end # if ( (arg[0]
            # See if there are pairs of pattern:::substitutions  
            if (arg.include?(@delimiter) && arg.split(@delimiter).length == 2)
              s << a.split(@delimiter)
              puts "Argument #{n}: #{a.split(@delimiter)}"
              n += 1
            end
            
            # if no command line pairs of pattern:::replacements found,
            # then default to replacing all of the Rails strings  
            if(@sub_strs.empty?)
                @sub_strs = RAILS_SUB_STRS
            end  
            # if we have an input file,
            # then open and read the pattern:::substitution 
            # pairs into the @sub_strs array
            if(!(@infile.empty?))  
              f = File.open(@infile, "r")
              lines = f.readlines 
              lines.each do |line|  
                @sub_strs << line.split(@delimiter)     
              end
            end # lines.each
            if(!@sub_strs.empty?)
              0.upto(@sub_strs.length - 1) do |n|
                puts "@sub_strs[n] = #{@sub_strs[n]}"
              end
            end       
            if DEBUG
              puts "State = #{STATE_STRS[@state]}"
            end
          when DELIMIT
            if(@verbose)
              puts "state = DELIMIT"
              puts "delimiter = #{arg}"
            end  
            @delimiter = arg
            @state = NONE
          when EXTENSIONS
            if(@verbose)
              puts "state = EXTENSIONS"
              puts "@extensions = #{arg}"
            end  
            @extensions = arg
            @state = NONE
          when VERBOSE   
            @verbose = true
            if(@verbose)
              puts "state = VERBOSE"
            end  
          when DONE
            if(@verbose)
              puts "state = DONE"
            end  
            break
        end # case @state 
      end # ARGV.each
    end
    
    def rootDirectory  
      @rootDirectory  
    end  
    
    def RecurseTree  
      totalFiles = 0;  
  
      Find.find(@rootDirectory) do |path|   
        if FileTest.directory?(path)  
          # determine if this is a directory we don't like...  
          if @excludedDirectoryNames.include?(File.basename(path.downcase))  
            Find.prune #don't look in this directory  
          else  
            next  
          end  
        else # we have a file  
          filetype = File.basename(path.downcase).split(".").last  
          # determine if this file is an included filetype
          if @includedFileTypes.include?(filetype)  
            # yes, so append it to the file list
            @flist << path  
            totalFiles = totalFiles + 1  # increment the total file count
          end  
        end  
      end  
      
      if DEBUG
        puts "total files = " << totalFiles.to_s  
      end
      
      0.upto(@flist.length - 1) do |x|
        f = File.open(@flist[x])
        0.upto(@sub_strs.length - 1) do |y|
          f.replace(@sub_strs[y][0],@sub_strs[y][1])
        end
      end
      # only return unique filenames
      CHANGED.uniq!
    end  
  end   
  
end
include Rails3Subs  
#puts INTRO

SearchAndReplace.new.RecurseTree  
if CHANGED.length > 0 then
  puts "The following files were changed:"
  0.upto(CHANGED.length - 1) do |x|
    puts CHANGED[x]
  end
else
  puts "No substitutions were found so no files were changed."
end  
