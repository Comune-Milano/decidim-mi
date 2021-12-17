Rails.application.routes.draw do

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Decidim::Core::Engine => '/'
  #mount Decidim::Core::Engine => '/decidim/'
  #get '/' => "application#redirect_to_decidim" 

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'sso_login_test' => "sso_login_test#show"
  post 'sso_login_test' => "sso_login_test#pippo"

  get 'ssologin' => "sso_login#pippo"
  post 'ssologin' => "sso_login#login"

  post "sender" => "sender#index"

  get 'decidim/anagrafe' => "sso_login#testws"

  #post '/' =>  "sso_login#login"

  get 'login_error' => 'login_error#index'
  get 'decidim/callback' => "sso_login#post"
 
  get 'change_status' => 'emendation_change_status#edit'
  
end

