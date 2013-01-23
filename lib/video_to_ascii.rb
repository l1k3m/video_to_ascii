require "video_to_ascii/version"
require 'asciiart'
require 'streamio-ffmpeg'

class VideoToAscii
  attr_accessor :ascii_images

  def initialize()
    @ascii_images = []

    create_required_directories()
    capture_video()

    video = FFMPEG::Movie.new('videos/video.avi')

    screenshots_from_video(video)
    convert_all_images()

    puts "Press any key to watch."
    ready = gets.chomp!

    if ready
      system("clear")
      play_movie()
    end

    cleanup()
  end

  def create_required_directories
    `mkdir videos images`
  end

  def capture_video
    puts "Recording Video..."
    `./lib/wacaw --video videos/video`
  end

  def screenshots_from_video(video)
    step_arr = []

    (0.0...video.duration).step(0.1).each { |x| step_arr << x.round(2) }

    step_arr.each_with_index do |step, i|
      video.screenshot("images/#{i}.jpg", seek_time: step)
    end
  end

  def convert_all_images
    images = []
    Dir.glob('images/*.jpg') { |i| images << i }

    puts "asciiing the world"
    images.each do |image|
      convert_to_ascii(image)
    end
  end

  def play_movie
    @ascii_images.each do |image|
      sleep 0.1
      puts image
      system("clear")
    end
  end

  def convert_to_ascii(image)
      image = AsciiArt.new("#{image}")
      @ascii_images << image.to_ascii_art
  end

  def cleanup
    `rm -rf images videos`
  end

end
