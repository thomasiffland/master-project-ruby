# myapp.rb
require 'sinatra'
require 'open3'
set :port, 8082
set :bind, '0.0.0.0'
require 'fileutils'


def create_images_folder()
  unless File.directory?('/tmp/images')
    FileUtils.mkdir_p '/tmp/images'
  end
end

post '/exifdata' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  file_extension = File.extname(@filename)

  create_images_folder()


  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    # file_without_extension = File.absolute_path(f).split(".")
    output,_ = Open3.capture2('exiftool '+File.absolute_path(f))
    # send_file(File.absolute_path(f))
    return output
  end


end

post '/exifdata/filtered' do

  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  file_extension = File.extname(@filename)
  filter = params[:filter]

  create_images_folder()

  File.open("/tmp/images/#{SecureRandom.uuid}#{file_extension}", 'wb') do |f|
    f.write(file.read)
    output,_ = Open3.capture2("exiftool #{File.absolute_path(f)} | grep '#{filter}'")
    return output
  end


end