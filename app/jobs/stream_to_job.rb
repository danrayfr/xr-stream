class StreamToJob < ApplicationJob
  queue_as :default

  def perform(file, twitch_stream_key)

    return unless File.exist?(file)

    command = <<~CMD
      ffmpeg -re -i #{file} \
        -c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k \
        -pix_fmt yuv420p -g 60 -c:a aac -b:a 160k -ar 44100 \
        -f flv rtmp://live.twitch.tv/app/#{twitch_stream_key}
    CMD

    Rails.logger.info("Starting streaming...")
    system(command)
  rescue => e
    Rails.logger.error("Failed to stream: #{e.message}")
  end
end
