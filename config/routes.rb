Rails.application.routes.draw do
  resource :parametrage

post  '/parametrage/add_generation', to: 'parametrages#create_generation', as: 'add_generation'
delete '/parametrage/delete_generation/:id', to: 'parametrages#destroy_generation', as: 'delete_generation'
get   '/parametrage/edit_generation/:id', to: 'parametrages#edit_generation', as: 'edit_generation'
patch '/parametrage/update_generation/:id', to: 'parametrages#update_generation', as: 'update_generation'


  
  devise_for :users, 
    skip: [:sessions, :registrations], # Important : skip les routes qu'on va redéfinir
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords',
      unlocks: 'users/unlocks'
    }

  # Redéfinition personnalisée des routes principales
  devise_scope :user do
  # sessions
  get    'connexion'   => 'users/sessions#new',     as: :login
  post   'connexion'   => 'users/sessions#create',  as: :user_session
  delete 'deconnexion' => 'users/sessions#destroy', as: :logout

  # registrations (inscription + edition)
  get   'inscription' => 'users/registrations#new',    as: :signup
  post  'inscription' => 'users/registrations#create', as: :user_registration

  get   'profil/edit' => 'users/registrations#edit',   as: :edit_user_registration
  put   'profil'      => 'users/registrations#update'
  patch 'profil'      => 'users/registrations#update'
end

  resources :users do
    member do
      get :arbre
    end
  end


  namespace :admin do
    resources :users do
      member do
        patch :block
        patch :unblock
      end
    end
  end

 get 'mon_profil', to: 'users#show', as: :user_profile




  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "homes#accueil"
  # Defines the root path route ("/")
  get "dashboard/index"
  get "dashboard/admin"
  get "dashboard/list_utilisateur"
  get "dashboard/souscription_list"
  get "template/index"
  get 'subscriptions/index', to: 'subscriptions#index', as: 'souscriptions'


post '/dashboard/force_validate/:id', to: 'dashboard#force_validate', as: :dashboard_force_validate
delete '/dashboard/delete_subscription/:id', to: 'dashboard#delete_subscription', as: :dashboard_delete_subscription

  patch 'dashboard/update_balance/:id', to: 'dashboard#update_balance', as: :update_balance


  resources :subscriptions do
    member do
      post 'process_payment', as: :process_payment
      patch :update_statut
    end
    collection do
      get :index, as: 'souscriptions'
      get :callback
      get :success
      get :failed
    end
  end

  resources :retraits do
    member do
      patch :valider
      patch :rejeter
    end
  end
end
