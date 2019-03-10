# myapp.rb
require 'sinatra'
require 'open3'
require 'net/http'
set :port, 8081
set :bind, '0.0.0.0'
require 'rest_client'
require 'fileutils'

uri = 'http://localhost:8083/resize'


def create_images_folder()
  unless File.directory?('/tmp/images')
    FileUtils.mkdir_p '/tmp/images'
  end
end

post '/grayscale' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")
    Open3.pipeline(['convert', File.absolute_path(f), '-colorspace', 'Gray', file_without_extension[0] + "_grayscale.jpg"])
    send_file(file_without_extension[0] + "_grayscale.jpg")
  end


end

post '/grayscale/resize' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  size = params[:size]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")
    Open3.pipeline(['convert',File.absolute_path(f), '-colorspace','Gray', file_without_extension[0] + "_grayscale.jpg"])
    res = RestClient.post(uri,{:file => File.new(file_without_extension[0] + "_grayscale.jpg"),:size => size})
    File.open(file_without_extension[0]+"_grayscaleresized"+file_extension, 'wb') do |f|
      f.write(res.body)
      send_file(file_without_extension[0] + "_grayscaleresized" + file_extension)
    end
  end
end