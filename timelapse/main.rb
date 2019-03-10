# myapp.rb
require 'sinatra'
require 'open3'
require 'fileutils'

set :port, 8084
set :bind, '0.0.0.0'


def create_images_folder()
  unless File.directory?('/tmp/images')
    FileUtils.mkdir_p '/tmp/images'
  end
end

post '/timelapse' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  framerate = params[:framerate]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")
    FileUtils.mkdir(file_without_extension[0]) unless Dir.exists?(file_without_extension[0])
    Open3.pipeline(['unzip',File.absolute_path(f), '-d', file_without_extension[0]])
    Open3.pipeline(["ffmpeg", "-r", framerate, "-pattern_type", "glob", "-i", "*.png", "-vcodec", "libx264", "timelapse.mp4"],:chdir=>file_without_extension[0])
    send_file(file_without_extension[0] + "/timelapse.mp4")
    return "Ok"
  end


end