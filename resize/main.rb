# myapp.rb
require 'sinatra'
require 'open3'
set :port, 8083
set :bind, '0.0.0.0'
require 'fileutils'

require 'rest_client'
uri = 'exifdata:8082/exifdata/filtered'

def create_images_folder()
  unless File.directory?('/tmp/images')
    FileUtils.mkdir_p '/tmp/images'
  end
end

post '/resize' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  size = params[:size]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")
    Open3.pipeline(['convert',File.absolute_path(f), '-resize',size, file_without_extension[0] + "_resized" + file_extension])
    send_file(file_without_extension[0] + "_resized" + file_extension)
  end
end

post '/resize/percent' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  percent = params[:percent]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    file_without_extension = File.absolute_path(f).split(".")

    res = RestClient.post(uri,{:file => File.new(File.absolute_path(f)),:filter => "Image Width"})
    size = res.body.to_s.split(":")[1].strip!().to_f * (percent.to_f() / 100)
    Open3.pipeline(['convert', File.absolute_path(f), '-resize', "#{size}x#{size}", file_without_extension[0] + "_resized" + file_extension])
    send_file(file_without_extension[0] + "_resized" + file_extension)
  end
end