Rails.application.routes.draw do

  #get 'api', :to => 'deny_api#deny_all', :as => 'deny_api_root'
  #post 'api', :to => 'deny_api#deny_all', :as => 'deny_api_root_post'
  #get 'api/:everything', :to => 'deny_api#deny_all', :as => 'deny_api_page'
  #post 'api/:everything', :to => 'deny_api#deny_all', :as => 'deny_api_pste_post'
	
  post 'admin/signatures/:id/:type/reject_send_notifications', :to => 'admin/manage_signature#reject_send_notification_custom', :as =>'reject_send_signature_notification'

  post 'admin/signatures/:id/:type/accept_send_notifications', :to => 'admin/manage_signature#accept_send_notification_custom', :as =>'accept_send_signature_notification'

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
  
   get '/ssologin' => "sso_login#pippo" 
   
   get '/logout' => 'sso_login#logout'
   get '/logout/slo' => 'sso_login#sp_logout_request'
   get '/logout/spid' => 'sso_login#spid_logout_request'
   
  get '/login_error' => 'login_error#index'


  get '/paperino' => "application#saml_settings"
  get '/saml2/callback' => "sso_login#post"
  get '/saml2/logout_callback' => 'sso_login#saml_logout'
  post '/users/auth/saml/spslo' => 'sso_login#process_logout_response'

  get '/saml3/callback' => "sso_login#logout_idp"
  

  post "/sender" => "sender#index", :defaults => { :format => 'js' } #invia la mail del form di partecipazione

  get 'cerca_utente' => 'cerca_utente#cerca_utente'
  get "/under_construction" => "courtesy_page#show"

  get 'edit_not_allowed' => 'edit_not_allowed#check'
  
 
get '/get_areas_from_type/:type_id' => 'get_areas_from_type#select'  

end
