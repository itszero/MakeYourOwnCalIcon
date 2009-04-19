#!/usr/bin/ruby
require 'rubygems'
require 'sinatra'
require 'RMagick'
include Magick
require 'pathname'

FONTPATH = Pathname.new($0).realpath.to_s

get '/' do
  open('public/index.html').read
end

get '/gen_icon' do
  headers['Content-Type'] = 'image/png'

  params.delete_if { |k, v| v == "" }
  params[:sat] = 1.0 if !params[:sat]
  params[:hue] = 1.0 if !params[:hue]

  canvas = Image.new(450, 475) do
    self.background_color = 'transparent'
  end

  base = ImageList.new('base.png')
  canvas.composite!(base, 0, 36, OverCompositeOp)
  top_original = ImageList.new('top.png')
  top = top_original.modulate(1.0, params[:sat].to_f, params[:hue].to_f)
  canvas.composite!(top, 15, 36, OverCompositeOp)
  ring = ImageList.new('ring.png')
  canvas.composite!(ring, 85, 0, OverCompositeOp)

  canvasTopText = Image.new(300, 90) do
    self.background_color = 'transparent'
  end
  top_text = Draw.new
  top_text.annotate(canvasTopText, 0, 0, 0, 80, params[:month] || "FEB") {
    self.pointsize = 100
    self.font_weight = BoldWeight
    self.font = FONTPATH 
    self.fill = 'white'
  }
  gradTopText = GradientFill.new(0, 0, 300, 0, "#FFFFFF", "#C0C0C0")
  canvasTopTextFill = Image.new(300, 95, gradTopText)
  canvasTopText.composite!(canvasTopTextFill, CenterGravity, InCompositeOp)
  canvasTopText.trim!
  canvas.composite!(canvasTopText, 450 / 2 - canvasTopText.columns / 2, 90, OverCompositeOp)

  canvasDay = Image.new(300, 300) do
    self.background_color = 'transparent'
  end
  day_text = Draw.new
  day_text.annotate(canvasDay, 0, 0, 0, 270, params[:day] || "29") {
    self.pointsize = 220
    self.font_weight = BoldWeight
    self.font = FONTPATH
    self.fill = 'white'
  }
  gradTopText = GradientFill.new(0, 0, 300, 0, "#AAAAAA", "#000000")
  canvasDayFill = Image.new(300, 300, gradTopText)
  canvasDay.composite!(canvasDayFill, CenterGravity, InCompositeOp)
  canvasDay.trim!
  canvas.composite!(canvasDay, 450 / 2 - canvasDay.columns / 2, 200, OverCompositeOp)

  canvasDesc = Image.new(400, 80) do
    self.background_color = 'transparent'
  end
  desc_text = Draw.new
  desc_text.annotate(canvasDesc, 0, 0, 0, 30, params[:desc] || "Server Error") {
    self.pointsize = 40
    self.font_weight = BoldWeight
    self.font = FONTPATH
    self.fill = '#ACACAC'
  }
  canvasDesc.trim!
  canvas.composite!(canvasDesc, 450 / 2 - canvasDesc.columns / 2, 390, OverCompositeOp)

  canvas.format = 'png'
  canvas.to_blob
end
