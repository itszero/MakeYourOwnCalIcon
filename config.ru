require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :environment => :production
)

require 'make_your_cal_icon.rb'
run Sinatra::Application
