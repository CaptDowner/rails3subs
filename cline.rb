#!/usr/local/bin/ruby 

# == Synopsis 
#   This is a program to demonstrate processing of command line arguments
#
# == Examples
#   This command will replace all of the matching patterns in all
#   files from this directory and below with the substitution strings 
#   found in the foo.txt file.
#   
#     ruby3_subs foo.txt
#
#   Other examples:
#     rails3-subs -q bar.doc
#     rails3-subs --verbose foo.html
#
# == Usage 
#   rails3-subs [options] source_file
#
#   rails3-subs [options] pattern1:::replacement1 pattern2:::replacement2 pattern3:::replacement3
#   or
#   rails3-subs [options] ]filename.sub
#
#   For help use: rails3-subs -h
#
# == Options
#   -h, --help          Displays help message
#   -e, --ext=          Followed by a comma separated list of 
#                       file extensions to apply the substitutions to 
#   -i, --input=        Followed by [filename].sub containing pattern:::substitution list  
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -r  --rsep=          Set pattern:::substitution record separator (default = ":::")
#   -V, --verbose       Verbose output
#   TO DO - add additional options
#
# == Author
#   Steve Downie
#
# == Copyright
#   Copyright (c) 2010 Gulf Coast Digital Systems. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse' 
#require 'rdoc/usage'
require 'ostruct'
require 'date'

USAGE =<<eos
== Usage 
  rails3-subs [options] source_file

  rails3-subs [options] pattern1:::replacement1 pattern2:::replacement2 pattern3:::replacement3
  or
  rails3-subs [options] ]filename.sub

  For help use: rails3-subs -h

== Options
  -h, --help          Displays help message
  -e, --ext=          Followed by a comma separated list of 
                      file extensions to apply the substitutions to 
  -i, --input=        Followed by [filename].sub containing pattern:::substitution list  
  -v, --version       Display the version, then exit
  -q, --quiet         Output as little as possible, overrides verbose
  -r  --rsep=         Set pattern:::substitution record separator (default = ":::")
  -V, --verbose       Verbose output

eos
class R3Subs
  VERSION = '0.0.1'
  
  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    
    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.quiet = false
    # TO DO - add additional defaults
  end

  # Parse options, check arguments, then process the command
  def run
        
    if parsed_options? && arguments_valid? 
      
      puts "Start at #{DateTime.now}\n\n" if @options.verbose
      
      output_options if @options.verbose # [Optional]
            
      process_arguments            
      process_command
      
      puts "\nFinished at #{DateTime.now}" if @options.verbose
      
    else
      output_usage
    end
      
  end
  
  protected
  
    def parsed_options?
      
      # Specify options
      opts = OptionParser.new 
      opts.on('-v', '--version')    { output_version ; exit 0 }
      opts.on('-h', '--help')       { output_help }
      opts.on('-V', '--verbose')    { @options.verbose = true }  
      opts.on('-q', '--quiet')      { @options.quiet = true }
      # TO DO - add additional options
            
      opts.parse!(@arguments) rescue return false
      
      process_options
      true      
    end

    # Performs post-parse processing on options
    def process_options
      @options.verbose = false if @options.quiet
    end
    
    def output_options
      puts "Options:\n"
      
      @options.marshal_dump.each do |name, val|        
        puts "  #{name} = #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
      # TO DO - implement your real logic here
      true if @arguments.length == 1 
    end
    
    # Setup the arguments
    def process_arguments
      # TO DO - place in local vars, etc
    end
    
    def output_help
      output_version
      RDoc::usage() #exits app
    end
    
    def output_usage
      puts USAGE
#      RDoc::usage('usage') # gets usage from comments above
    end
    
    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end
    
    def process_command
      # TO DO - do whatever this app does
      
      #process_standard_input # [Optional]
    end

    def process_standard_input
      input = @stdin.read      
      # TO DO - process input
      
      # [Optional]
      # @stdin.each do |line| 
      #  # TO DO - process each line
      #end
    end
end

# TO DO - Add your Modules, Classes, etc
# Create and run the application
app = R3Subs.new(ARGV, STDIN)
app.run
