#!/usr/local/bin/ruby
#---------------------------------------------------------------------------------
# Script to search and replace RAILS constants and methods 
# with Rails 3 replacements
#---------------------------------------------------------------------------------
$DEBUG=true

puts "This script will search and replace the following list of deprecated"
puts "Rails constants and method calls with their Rails 3 replacements"
puts " "
puts "Original Rails constants and methods                 |  Rails 3 replacements"
puts "-----------------------------------------------------------------------------"
puts "RAILS_ENV                                            => Rails.env"
puts "RAILS_ROOT                                           => Rails.root"
puts "RAILS_CACHE                                          => Rails.cache"
puts "RAILS_DEFAULT_LOGGER                                 => Rails.logger"
puts "filter_parameter_logging                             => config.filter_parameters"
puts "AC::Dispatcher.before_dispath                        => ActionDispatch::Callbacks.before"
puts "AC::Dispatcher.to_prepare                            => config.to_prepare"
puts "AC::Dispatcher                                       => Rails::Application"
puts "config.action_controller.consider_all_requests_local => Rails.application.config.consider_all_requests_local"
puts "config.action_controller.allow_concurrency           => Rails.application.config.allow_concurrency"
puts "benchmark(:level)                                    => benchmark(\"message\", :level => level)"
puts "config.view_path                                     => path.apps.views"
puts "config.routes_configuration_file                     => paths.config_routes"
puts "config.database_configuration_file                   => paths.config.database"
puts "config.controller_paths                              => paths.app.controllers"
puts "config.log_path                                      => paths.log"
puts " "
puts "Press 'y' to execute replacement, 'n' will abort: "


$Sub_strs= [ ["RAILS_ENV","Rails.env"],
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

require 'find'  

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
      lines.each do |line|
        write(line)
      end
      close
    end
  end
end

class SearchAndReplace
  attr_accessor :flist
  
  def initialize()  
    @rootDirectory =IO.readlines("sr.cfg")[1].strip!  
    @includedFileTypes =IO.readlines("sr.cfg")[3].downcase.split(",")  
    @excludedDirectoryNames =IO.readlines("sr.cfg")[5].downcase.split(",")  
    @flist = Array::new
    puts @includedFileTypes  
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
    puts "total files = " << totalFiles.to_s  
    0.upto(@flist.length - 1) do |x|
      f = File.open(@flist[x])
      0.upto($Sub_strs.length - 1) do |y|
        f.replace($Sub_strs[y][0],$Sub_strs[y][1])
        if $DEBUG        
          puts "Replaced #{$Sub_strs[y][0]} with #{$Sub_strs[y][1]} in #{@flist[x]}\n"   
        end  
      end
    end  
  end  
end   

SearchAndReplace.new.RecurseTree  

=begin
::Root Directory  
c:\some\directory\path  
::Included File Types (extensions)  
cs,aspx,vb,asmx,css,xml,resx,ascx,master,sitemap,sql,  
::Excluded Directory Names  
Tests,Documentation,.svn,  

glob_path, exp_search, exp_replace = 'temp/*.txt','five', 'six'
Dir.glob(glob_path).each do |file| 
  buffer = File.new(file,'r').read.gsub(/#{exp_search}/,exp_replace)
  File.open(file,'w') {|fw| fw.write(buffer)}
end
=end
=begin
# Another possibility:
# ruby -pi.bak -e "$.gsub!(/findstring/, 'replace_string')" path/to/files/*.txt
#
=end
=begin
require 'find' 
if ARGV.size < 3 || ARGV[0] == '-h'
  puts "findreplace.rb Finds and replaces strings in the given directory."
  puts "syntax: findreplace.rb PATH find_string replace_string [ignore_dirs]"
  exit
end

Find.find(ARGV[0]) do |file_name| 
  if File.file? file_name
    file = File.new(file_name)
    lines = file.readlines
    file.close

    changes = false
    lines.each do |line|
      changes = true if line.gsub!(/#{ARGV[1]}/, ARGV[2])
    end

    #  Don't write the file if there are no changes
    if changes
      file = File.new(file_name,'w')
      lines.each do |line|
        file.write(line)
      end
      file.close
    end
  end
    
  Find.prune if ARGV[3] && file_name =~ /#{ARGV[3]}/  
end
=end    
=begin
grep -rl oldstring . |xargs sed -i -e 's/oldstring/newstring/'
=end
