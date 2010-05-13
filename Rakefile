require 'rubygems'
require 'rake'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/rails3subs'
require 'rake'
require 'echoe'
Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures


Echoe.new('rails3subs','0.1.1') do |p|
  p.description = "A gem to do string substitutions required for Rails 3"
  p.url = "http://gcdsystems.com/captdowner/rails3subs"
  p.author = "Steve Downie"
  p.email = "captdowner @nospam@ comcast.net"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
#$hoe = Hoe.spec 'rails3subs' do
#  self.developer 'Steve Downie', 'captdowner at comcast dot net'
#  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
#  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

#end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
