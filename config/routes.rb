Rails.application.routes.draw do
  resource :session, only: %i[create destroy]
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  constraints ->(_req) { Rails.env.development? || Rails.env.test? } do
    get "internal/styleguide", to: "internal/styleguide#index", as: :styleguide
  end

  root "pages#home"

  get "auth", to: "sessions#new", as: :auth
  get "signup", to: "sessions#new", as: :signup, defaults: { mode: "signup" }
  post "signup", to: "registrations#create"

  get "confidentialite", to: "legal#privacy"
  get "mentions-legales", to: "legal#legal_notice"
  get "cgu", to: "legal#terms"
  get "avis", to: "feedbacks#new"
  post "avis", to: "feedbacks#create"
  get "sitemap.xml", to: "sitemaps#show", defaults: { format: "xml" }

  get "dashboard", to: "tracks#index", as: :dashboard

  resources :tracks do
    member do
      get :calendar
      post :pause
      post :resume
      post :restart
      post :close
    end
    resources :consumptions, only: %i[create destroy]
  end

  resource :settings, only: %i[show update] do
    get :export
    delete :destroy_account
  end
end
