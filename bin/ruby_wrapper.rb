#!/usr/bin/env ruby
# encoding: UTF-8
#
# ruby_wrapper.rb (project wrapper)
#
# Delegates to the shared master wrapper.
master = "/home/rvm/.rvm/bin/ruby_wrapper.rb"
app_root = File.expand_path("..", __dir__)
exec(master, app_root, *ARGV)
