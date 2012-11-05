CampanifyWeb::Application.routes.draw do

  resources :pages, :only => [:index, :show] do
    get :addons, :on => :collection
  end

  devise_for :users, :skip => [:registrations]

  namespace "api" do
    resources :campaigns, :only => [:index, :create, :update, :destroy]
  end    
  
  root :to => "pages#index"
  
end
