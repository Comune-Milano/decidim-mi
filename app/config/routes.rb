Rails.application.routes.draw do

  post 'admin/signatures/:id/:type/reject_send_notifications_municipale', :to => 'admin/manage_signature#reject_send_notification_custom_municipale', :as =>'reject_send_signature_notification_municipale'
  post 'admin/signatures/:id/:type/reject_send_notifications_comunale', :to => 'admin/manage_signature#reject_send_notification_custom_comunale', :as =>'reject_send_signature_notification_comunale'

  post 'admin/signatures/:id/:type/accept_send_notifications_municipale', :to => 'admin/manage_signature#accept_send_notification_custom_municipale', :as =>'accept_send_signature_notification_municipale'
  post 'admin/signatures/:id/:type/accept_send_notifications_comunale', :to => 'admin/manage_signature#accept_send_notification_custom_comunale', :as =>'accept_send_signature_notification_comunale'

  get 'admin/download/pdf_signeds/:id', :to => 'admin/pdf_signeds#download',  :as => 'pdf_signeds_download'

  get 'admin/pdf_signeds/:id/:type', :to => 'admin/pdf_signeds#index',  :as => 'pdf_signeds'
  post 'admin/pdf_signeds/:id/:type' => 'admin/pdf_signeds#create'
  delete 'admin/pdf_signeds/:id/:type', :to => 'admin/pdf_signeds#destroy', :as => 'pdf_signed'

  get 'admin/pdf_signeds/:id/new/:type', :to => 'admin/pdf_signeds#new', :as =>'new_pdf_signed'

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

  get 'edit_not_allowed' => 'edit_not_allowed#check'

  get 'pluto' => "auriga#test_login"

  get 'pdf_signed_redirect' => 'admin/pdf_signed_redirect#index'

  #post 'admin/signatures/:id/:type/send_notifications', :to => 'admin/signature_notification#send_notification', :as =>'send_signature_notification_execute'


end

