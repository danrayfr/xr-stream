class StreamToJob < ApplicationJob
  queue_as :default

  require "streamio-ffmpeg"
  def perform(file, twitch_stream_key)

    return unless File.exist?(file)

    stream_to_twitch(file, twitch_stream_key)
  rescue => e
    Rails.logger.error("Failed to stream: #{e.message}")
  end

  private
    def stream_to_twitch(file, twitch_stream_key)
      # command = <<~CMD
      #   ffmpeg -re -i #{file} \
      #     -c:v libx264 -preset veryfast \
      #     -pix_fmt yuv420p -g 60 -c:a aac -b:a 128k -ar 44100 \
      #     -f flv rtmp://live.twitch.tv/app/#{twitch_stream_key}
      #     -loglevel debug
      # CMD

      command = <<~CMD
        ffmpeg -re -i #{file} -c:v libx264 -preset veryfast -g 60 \
          -c:a aac -b:a 128k -ar 44100 \
          -f flv rtmp://live.twitch.tv/app/#{twitch_stream_key}
      CMD

      Rails.logger.info("Starting streaming...")
      system(command)
    end
end
