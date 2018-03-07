Rails.application.routes.draw do
  resources :home, only: [] do
    collection do
      post :upload
      get :output
    end
  end
  root 'home#index'
end
