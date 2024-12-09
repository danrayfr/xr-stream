import { Controller } from "@hotwired/stimulus"
import "gapi"

// Connects to data-controller="broadcasting"
export default class extends Controller {
  static values = {
    clientId: String,
    apiKey: String
  }

  connect() {
    console.log("Initialize broadcasting...", this.clientIdValue);
    console.log("apiKey", this.apiKeyValue)
    this.Initialize();
  }

  Initialize() {
    if (this.clientIdValue && this.apiKeyValue) {
      gapi.load("client::auth2", this.initClient)
    } else {
      console.error("Credentials must be defined")
    }
  }

  initClient() {
    gapi.client
      .init({
        apiKey: "AIzaSyAGyTRG_EICz4ahFQeIYKMlbKi1_nPtaYA",
        clientId: "111235189071-10kjof6rs8jhv2h50mv80i3bsds1pmhr.apps.googleusercontent.com",
        discoveryDocs: "https://www.googleapis.com/discovery/v1/apis/youtube/v3/rest",
        scope: 'https://www.googleapis.com/auth/youtube.force-ssl',
      })
      .then(function() {
        GoogleAuth = gapi.auth2.getAuthInstance()

        // Listen for sign-in state changes.
        GoogleAuth.isSignedIn.listen(updateSigninStatus)

        // Handle initial sign-in state.
        var user = GoogleAuth.currentUser.get()
        console.log("user: ", JSON.stringify(user))

        if (!user) {
          setSigninStatus()
        }
      })
  }
}
