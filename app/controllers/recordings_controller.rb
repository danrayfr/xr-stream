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

    File.open("tmp/stream.webm", "ab") do |f|
      f.write(chunk.read)
    end

    head :ok
  end

  private
    def recording_params
      params.require(:recording).permit(:file)
    end
end
