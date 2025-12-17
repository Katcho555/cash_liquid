Rails.application.routes.draw do
  resources :products
  resources :payments, only: [:new, :create]

  namespace :admin do
    get 'reward_claims/index'
  end
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
  

  namespace :users do
    post 'spin', to: 'spin#create'
    post 'redeem_reward', to: 'spin#redeem_reward'
    get 'spin/index' # optional: page showing wheel
  end

  post '/spin', to: 'users/spin#create' # API convenience

  resource :spin, only: [:show]


  namespace :admin do
    resources :users do
      member do
        patch :block
        patch :unblock
      end
    end
    resources :spin_configurations
    resource :spin_setting, only: [:show, :edit, :update]
    resources :spin_logs, only: [:index, :show]
    resources :reward_claims, only: [:index]
    get '/', to: 'dashboard#index', as: :dashboard
    get 'bonus', to: 'bonus#index', as: :bonus_root
  end


  get 'bonus_recompenses/index'

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
      get :my_subscriptions
      post :credit_daily
    end
  end

  resources :retraits do
    member do
      patch :valider
      patch :rejeter
    end
  end
end
