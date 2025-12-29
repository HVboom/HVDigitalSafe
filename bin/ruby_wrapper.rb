#!/usr/bin/env ruby
# ruby_wrapper.rb (repo wrapper)
#
# Delegates to the central master wrapper to select Ruby/Gemset via .ruby-version/.ruby-gemset.
#
# Master: /home/rvm/.rvm/bin/rails_ruby_wrapper.rb
#
require "pathname"
app_root = Pathname.new(__dir__).join("..").expand_path.to_s
exec "/home/rvm/.rvm/bin/rails_ruby_wrapper.rb", app_root, *ARGV
