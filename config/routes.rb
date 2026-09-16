Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  constraints ->(_req) { Rails.env.development? || Rails.env.test? } do
    get "internal/styleguide", to: "internal/styleguide#index", as: :styleguide
  end

  root "pages#home"

  get "auth", to: "pages#soon", as: :auth
  get "signup", to: "pages#soon", as: :signup
end
