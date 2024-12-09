import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="recording"
export default class extends Controller {
  static targets = ["video"]

  connect() {
    this.stream = null
    this.recorder = null
    this.chunks = []
    console.log(this.chunks)
  }

  async start() {
    console.log("Start recording")
    this.stream = await this.startCapture();
    this.recorder = await this.startRecording(this.stream, this.chunks)
  }

  async stop() {
    console.log("Stop Recording")
    if (this.stream) {
      this.stopCapture(this.stream)
      console.log(this.chunks)
      this.stopRecording(this.recorder)
    } else {
      console.log("No active stream", this.stream)
    }
  }

  async save() {
    console.log("Save recording")
    const recording = await this.saveRecording(this.chunks)
    console.log(recording)
  }

  async startCapture() {
    let stream, voiceStream;

    try {
      stream = await navigator.mediaDevices.getDisplayMedia({ audio: true })
      voiceStream = await navigator.mediaDevices.getUserMedia({ video: false, audio: true })
    } catch(e) {
      console.log("error", e)
    }
    const tracks = [...stream.getTracks(), ...voiceStream.getTracks()]
    return new MediaStream(tracks)
  }

  stopCapture(stream) {
    stream.getTracks().forEach(track => track.stop())
  }

  async startRecording(stream, chunks) {
    const recorder = new MediaRecorder(stream)

    recorder.ondataavailable = async (e) => {
      chunks.push(e.data)
      if (e.data.size > 0) {
        const formData = new FormData()
        formData.append("chunk", e.data)

        const token = document.getElementsByName("csrf-token")[0].content

        await fetch("/recordings/stream", {
          method: "POST",
          headers: {
            "X-CSRF-Token": token
          },
          body: formData
        })
      }
    }
    
    recorder.start(1000)
    return recorder
  }

  stopRecording(stream) {
    if (stream) {
      stream.stop()
    }
  }

  async saveRecording(chunks) {
    const file = new File(chunks, {
      type: "video/webm",
      filename: "recording.webm",
    })

    const formData = new FormData()
    formData.append('recording[file]', file)
    const token = document.getElementsByName("csrf-token")[0].content
    const response = await fetch("/recordings", {
      method: "POST",
      headers: {
        "X-CSRF-Token": token
      },
      body: formData,
    })

    return response.json()
  }
}
