Rails.application.routes.draw do
  root "recordings#new"
  # get "/r/:key", to: "recordings#show"
  resources :recordings, except: :show

  get "/r/:key", to: "recordings#show", as: :slugged_recording
  post "/recordings/stream", to: "recordings#stream"
  post "/recordings/cleanup", to: "recordings#clean"

  direct :record_slug do |recording, options|
    route_for :slugged_recording, recording, options
  end

  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
