# myapp.rb
require 'sinatra'
require 'open3'
set :port, 8080
set :bind, '0.0.0.0'
require 'rest_client'
require 'fileutils'


uri = 'localhost:8081/grayscale'

def create_images_folder()
  unless File.directory?('/tmp/images')
    FileUtils.mkdir_p '/tmp/images'
  end
end


post '/rawtojpg' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  file_extension = File.extname(@filename)

  create_images_folder()

  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")

    Open3.pipeline(['dcraw', '-c', '-w', File.absolute_path(f)], ['convert', '-', file_without_extension[0] + ".jpg"])
    send_file(file_without_extension[0] + ".jpg")
  end


end

post '/rawtojpg/grayscale' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  file_extension = File.extname(@filename)

  create_images_folder()

  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")

    Open3.pipeline(['dcraw', '-c', '-w', File.absolute_path(f)], ['convert', '-', file_without_extension[0] + ".jpg"])
    res = RestClient.post(uri, {:file => File.new(File.absolute_path(f))})

    File.open(file_without_extension[0] + "_rawtograyscale.jpg", 'wb') do |f|
      f.write(res.body)
      send_file(file_without_extension[0] + "_rawtograyscale.jpg")
    end


  end


end

