Rails.application.routes.draw do
  
  get 'admin/pdf_signeds/:id/:type', :to => 'admin/pdf_signeds#index',  :as => 'pdf_signeds'
  post 'admin/pdf_signeds/:id/:type' => 'admin/pdf_signeds#create'
  delete 'admin/pdf_signeds/:id/:type', :to => 'admin/pdf_signeds#destroy', :as => 'pdf_signed'

  get 'admin/pdf_signeds/:id/new/:type', :to => 'admin/pdf_signeds#new', :as =>'new_pdf_signed'

  #get 'admin/initiatives_offline_signatures/pdf/:id', :to => 'admin/manage_signature#index',  :as => 'manage_signatures'
  #get 'admin/initiatives_offline_signatures/pdf/create/:id' => 'admin/manage_signature#create' ,:defaults => { :format => 'csv' }
  #delete 'admin/initiatives_offline_signatures/pdf/:id/destroy', :to => 'admin/manage_signature#destroy', :as => 'manage_signature'
  #get 'admin/initiatives_offline_signatures/pdf/:id/new', :to => 'admin/manage_signature#new', :as =>'new_manage_signatured'

  get 'admin/offline_signatures/pdf/:id/:type', :to => 'admin/manage_signature#index',  :as => 'manage_signatures'
  get 'admin/offline_signatures/pdf/create/:id/:type' => 'admin/manage_signature#create' ,:defaults => { :format => 'csv' }
  delete 'admin/offline_signatures/pdf/:id/destroy/:type', :to => 'admin/manage_signature#destroy', :as => 'manage_signature'
  get 'admin/offline_signatures/pdf/:id/new/:type', :to => 'admin/manage_signature#new', :as =>'new_manage_signatured'


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

