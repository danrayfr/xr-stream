class RecordingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :stream

  def index
    @recordings = Recording.all
  end

  def new
    @recording = Recording.new
  end

  def show
    @recording = Recording.find_by(key: params[:key])
  end

  def create
    @recording = Recording.new(recording_params)

    if @recording.save
      render json: @recording
    else
      render json: @recording.errors.full_messages.to_sentence
    end
  end

  def stream
    chunk = params[:chunk]
    file = "tmp/stream.web"

    File.open(file, "ab") do |f|
      f.write(chunk.read)
    end

    twitch_stream_key = ENV["TWITCH_STREAM_KEY"]

    StreamToJob.perform_later(file, twitch_stream_key)

    head :ok
  end

  def clean
    file = Rails.root.join("tmp", "stream.web")
    Rails.logger.info("Looking for file: #{file}")

    if File.exist?(file)
      File.delete(file)
      Rails.logger.info("File deleted successfully: #{file}")
      render json: { message: "Temp file is deleted successfully" }, status: :ok
    else
      Rails.logger.warn("File not found: #{file}")
      render json: { message: "No file found" }, status: :not_found
    end
  end

  private
    def recording_params
      params.require(:recording).permit(:file)
    end
end
