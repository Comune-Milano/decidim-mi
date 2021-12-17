# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.

Devise.setup do |config|
	config.omniauth :keycloak_openid, "test1","PolB_lRYfOF3IZgP6rRA6FQiSCeStxmuwb_dw6xliaA", client_options: { site: "http://192.168.12.43:8080/auth/realms/DecidimMilano/protocol/saml", realm: "DecidimMilano" }, :strategy_class => OmniAuth::Strategies::KeycloakOpenId

	sp_key ='-----BEGIN RSA PRIVATE KEY-----MIIEowIBAAKCAQEAlBlYdMhl4HkUYsUN2OwzZyDCpSguwgLdRuQoYrt3dwBFUq1y6EENRWpXrtUyaY/sVT5fnWGl3s1DECyfyluHz3pGL7tCmOghegyxIcast2dO/pyUNl+e21jpZ1KJFmgtBEPIgAmksyq7r9iMFFwBxz6nBsBly7n8jbEhhxbotOLAI6tnZxVYKONIst/ETCIS9+FXIrbE/ixL3ORi06TV1rxDe31zAD3cwSBho6OTZxxTiok/qfZ2XHYQ2xHPD6XpR1NWTWq8nv6P1zV/KkmZ6bVy2QfSiZocXntmMgn5XLbUCarrpsAe+ZbLbcP3dDeE66wesFrYfzvVTGnPtaT8wQIDAQABAoIBACbzp51Hm+v3TJJRy7uTHE3ygt9XezzR7gsYNTsKnXgyHQmKzx8hBPGN77PvJQw4q2scNZ+6MBsyl4Hoirp5anX6bf1d3j1DSJLGRcxhacnvJQq4eg73BVwhvXnMbnvzOGvXvCNY5fWttqGgbe9o55rU8q9G6T81EqTdwri6IMh6OIDXjDvVq0uWCaUbAN+B2q1tCs90bGqhH+mersExlwJfW5q/3QON1Vu+XuAGVlUVerBPpSXhOxcVL4a8DR40vqmzgQy8sWfFfJOYxyDS61Bt+UDfRbA64BvqnJuG839jc3TdBY7twEDQakVAa0dU91GT+zjhiS+etDNScpVk6BUCgYEAzjXXXdDJ9F6A7FMmxR7FH086KbrAicos8eq7H9q734Gc3VMzhkA3KhOmg0FYTwMW4d8zBzZDbwmpuWr0TqI2snJOjrsQwd/SeD8stAdIYUu/GfaeCyFxpC3wpkiROjqrhhYfYZbNMJvYZeiaPw3yrPHPntOiTbjDhOFIcP3V/1cCgYEAt9uPUTJX8Ag1C238TiqLmTUUqT9l7vBAIHGUnpg/4vswkWtDaIxb7v85Zx5MqG0NzxcNPzdwqA87wCEYYUeMsmg2TJDTWJaVfXIznYDOz+v1o5dUZh7L+4MXoDOPEYaL/1YUWPpZkar6VkmF2lMbQ43eoFC7TbPVJ700218MDacCgYEAr7FUA8zGpPx33+Kg38ZtsVVxeuhw73VggeW69VMKS05FdpVTCwlfduwzLRXZxcgeEOh4s6ZaIhsbjq0/5ldzPusBX76mcmjfDDDXR7QEyVEeS2LCGT2vc3Do3uRpSDGAvsfOiPlRbh76aymZcivSHeQRP4OVf57yhx7i99JuKBUCgYAuu34YM2Wqu0tQVmp1K9dD3/wacOTl8Oc71+Lg1O4YMaTMsaj2oAaWHwVmMotlnCKQatmRIfReo1Caq07ZGyimCFsU5xLxR4VD141LEXx/2QgcxtBLDLTofw+4RqKs37gh9K1DWI7/uafb2uBM+CbL6vmVYi/ZtkYNzcfroqMbrQKBgAgNJkCXAmpf432wZVNIJgai+mSVw9XYem7zEJhHmV1Akw5U2long5kjMF4G1M2qnby4Jpq9GKV3XBkEpQRoAsCBYT2rd8R1w85zSE/amPBorNN9JSLeMLQDTPxB4V5+Zg386DbPClcDh3VPnpzShuLaUhn57wQZClXqiLS9dFJh-----END RSA PRIVATE KEY-----'

sp_certificate = 'MIICqzCCAZMCBgFxgpnOHjANBgkqhkiG9w0BAQsFADAZMRcwFQYDVQQDDA5EZWNpZGltIE1pbGFubzAeFw0yMDA0MTYxMDQ1NTBaFw0zMDA0MTYxMDQ3MzBaMBkxFzAVBgNVBAMMDkRlY2lkaW0gTWlsYW5vMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiSw8utaEt3zeMbJScD7L9NB6Fs84L8aOB4uI9xOflZWfUiOXs2+O0Nkc2uj5Uj3rrm8lv5z62J/fuuTV5Ydpa1WUFetSWy7a2NR9LNERfASV8YHJReJ/ok4/DeFTibvAKGGHLD9IM9/M7gjf99+YMiZQTTF32Fb4tQaiXWNwDN37d/RX6YVgu4JUXQN1KoqlgR4niG3iGjVkdkpvmo008ww8v9K0TunPC/qp65UfejLIyvlTw9Yd+yvTVcfhwLd0xKYKbnVF51sb3mjbwA0QAUzsXd/HRDZWJk938X2kpSlwA9z3FhWp3j72FiENIwv6xyvwjbsX9PAov4qLhksGswIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQA6xQXWAva49guyKKvNnWh0rK8dthWYmB7e3ZR7IfCTsPtmu/8U767fSp9ig66iACyt+D3RlKrf2sNhU+X1JZpxc9Amd6C+4x6wBhV09JKsAEoIwkkJ97OHqFLWP3iP6ns91mSW9djjoPeAk8FFeS7R62M8thO+ruNR8/mTj4TwfO4CRMXJgKkcCrGLHk8mtOHZvBW1iAf3NRQSKHnrFMmapZHCyoGx0sWRcULphbMJ6Uwl64fV2ifYQrMWAV4/HRwHTjj2WGDi58jjZSUFShniu84YG3CQetv6zxqzkB32mEz6LyxA9KCBox9MIPoUDifpDr8dyT/+lIjgxN7cDwF1'

idp_certificate = 'MIICrTCCAZUCBgFxiKdykjANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDDA9kZWNpZGltU3ZpbHVwcG8wHhcNMjAwNDE3MTQ1ODI3WhcNMzAwNDE3MTUwMDA3WjAaMRgwFgYDVQQDDA9kZWNpZGltU3ZpbHVwcG8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCUGVh0yGXgeRRixQ3Y7DNnIMKlKC7CAt1G5Chiu3d3AEVSrXLoQQ1Faleu1TJpj+xVPl+dYaXezUMQLJ/KW4fPekYvu0KY6CF6DLEhxqy3Z07+nJQ2X57bWOlnUokWaC0EQ8iACaSzKruv2IwUXAHHPqcGwGXLufyNsSGHFui04sAjq2dnFVgo40iy38RMIhL34VcitsT+LEvc5GLTpNXWvEN7fXMAPdzBIGGjo5NnHFOKiT+p9nZcdhDbEc8PpelHU1ZNarye/o/XNX8qSZnptXLZB9KJmhxee2YyCflcttQJquumwB75lsttw/d0N4TrrB6wWth/O9VMac+1pPzBAgMBAAEwDQYJKoZIhvcNAQELBQADggEBABWAsYvcMxMHi0msSObIMa7Jp1OClhEnqIA7rpEJ66W6KRPChtDYp1Dl8hX11ihcg7jpIvXwXIWQgIDrSoh3pq5m5KJttzkWJLYjBWrO92ZyQ75FlfpMAxIiUoO34rSdprlzAbH92MVwm2F469legXBlaXPhadeW317QCtqPy0xiMZQgEIfOzitd2LVlb+OA8fN6xi0wmui6DFICMuiC8FRpdYJgHrmR/AuOedM2eDFugOmroEmCt/mxuib6LqzAKhzr1GLYR5rifn/rEFp8sRDYV1BAq+2HaklB4cyH/kqRRxK7FSEqPdo9wpbWb5LE4VXmGykS+HGgSzIHCytrjis='

  config.omniauth :saml,
    	#	idp_cert:   "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiSw8utaEt3zeMbJScD7L9NB6Fs84L8aOB4uI9xOflZWfUiOXs2+O0Nkc2uj5Uj3rrm8lv5z62J/fuuTV5Ydpa1WUFetSWy7a2NR9LNERfASV8YHJReJ/ok4/DeFTibvAKGGHLD9IM9/M7gjf99+YMiZQTTF32Fb4tQaiXWNwDN37d/RX6YVgu4JUXQN1KoqlgR4niG3iGjVkdkpvmo008ww8v9K0TunPC/qp65UfejLIyvlTw9Yd+yvTVcfhwLd0xKYKbnVF51sb3mjbwA0QAUzsXd/HRDZWJk938X2kpSlwA9z3FhWp3j72FiENIwv6xyvwjbsX9PAov4qLhksGswIDAQAB",
protocol_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',   		
idp_sso_target_url: 'http://192.168.12.43:8080/auth/realms/DecidimMilano/protocol/saml',
		idp_slo_target_url: 'http://192.168.12.43:8080/auth/realms/DecidimMilano/protocol/saml',
idp_slo_session_destroy: proc { |_env, session| session.clear },
		issuer: 'decidimPippo',
	        #assertion_consumer_service_url: 'https://192.168.12.47/users/auth/saml/callback',
               # issuer: 'https://192.168.12.47/',
                #authn_context: 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport',
               # idp_sso_target_url: 'http://192.168.12.43:8080/auth/realms/DecidimMilano/protocol/saml',
                assertion_consumer_service_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                assertion_consumer_logout_service_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                idp_sso_target_url_runtime_params: {original_request_param: :mapped_idp_param},
                name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
		decidim_post: true,
              # name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
		 idp_cert: idp_certificate,
		strategy_class: OmniAuth::Strategies::SAML,
                request_attributes: {},
                attribute_statements: {email: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'],
                                       cdmCodiceFiscale: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
                                       givenName: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname'],
                                       sn: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname']},
                private_key: sp_key,
                certificate: sp_certificate,
                security: {authn_requests_signed: true,
                           logout_requests_signed: true,
                           logout_responses_signed: true,
                           metadata_signed: true,
                           digest_method: XMLSecurity::Document::SHA1,
                           signature_method: XMLSecurity::Document::RSA_SHA1,
                           embed_sign: true
}
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  # Devise will use the `secret_key_base` as its `secret_key`
  # by default. You can change it below and use your own secret key.
  # config.secret_key = 'e1f4e9899fb5e8b3123950b19cd0f6d22ecaa8c7fb792b6db5a939edc2b3bab722d06a6a46345ee9bf12caa0178408d6134ea92ed778977b8a7ed1007a0c6dbe'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = Decidim.config.mailer_sender

  # Configure the class responsible to send e-mails.
  config.mailer = "Decidim::DecidimDeviseMailer"

  # Configure the parent class responsible to send e-mails.
  config.parent_mailer = "Decidim::ApplicationMailer"

  config.parent_controller = "ActionController::Base"

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require "devise/orm/active_record"

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # config.http_authenticatable = false

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  # config.reload_routes = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 11. If
  # using other algorithms, it sets how many times you want the password to be hashed.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # algorithm), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 11

  # Set up a pepper to generate the hashed password.
  # config.pepper = 'da466a45a1744ca79cc920a565749cf42b1cbcda0478b299a0db973e1a157fc43d1f578ec8dd393b4ef104274272a3621d203f49f473432a46b8a28ecc9bb4ae'

  # Send a notification email when the user's password is changed
  # config.send_password_change_notification = false

  # ==> Configuration for :invitable
  # The period the generated invitation token is valid, after
  # this period, the invited resource won't be able to accept the invitation.
  # When invite_for is 0 (the default), the invitation won't expire.
  config.invite_for = 2.weeks

  # Number of invitations users can send.
  # - If invitation_limit is nil, there is no limit for invitations, users can
  # send unlimited invitations, invitation_limit column is not used.
  # - If invitation_limit is 0, users can't send invitations by default.
  # - If invitation_limit n > 0, users can send n invitations.
  # You can change invitation_limit column for some users so they can send more
  # or less invitations, even with global invitation_limit = 0
  # Default: nil
  # config.invitation_limit = 5

  # The key to be used to check existing users when sending an invitation
  # and the regexp used to test it when validate_on_invite is not set.
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/}
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/, :username => nil}

  # Flag that force a record to be valid before being actually invited
  # Default: false
  # config.validate_on_invite = true

  # Resend invitation if user with invited status is invited again
  # Default: true
  # config.resend_invitation = false

  # The class name of the inviting model. If this is nil,
  # the #invited_by association is declared to be polymorphic.
  # Default: nil
  # config.invited_by_class_name = 'User'

  # The foreign key to the inviting model (if invited_by_class_name is set)
  # Default: :invited_by_id
  # config.invited_by_foreign_key = :invited_by_id

  # The column name used for counter_cache column. If this is nil,
  # the #invited_by association is declared without counter_cache.
  # Default: nil
  # config.invited_by_counter_cache = :invitations_count

  # Auto-login after the user accepts the invite. If this is false,
  # the user will need to manually log in after accepting the invite.
  # Default: true
  config.allow_insecure_sign_in_after_accept = true

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  config.allow_unconfirmed_access_for = Decidim.unconfirmed_access_for

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  # config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [:email]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 6..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = 1.week

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  config.last_attempt_warning = true

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  # config.sign_in_after_reset_password = true

  # ==> Configuration for :encryptable
  # Allow you to use another hashing or encryption algorithm besides bcrypt (default).
  # You can use :sha1, :sha512 or algorithms from others authentication tools as
  # :clearance_sha1, :authlogic_sha512 (then you should set stretches above to 20
  # for default behavior) and :restful_authentication_sha1 (then you should set
  # stretches to 10, and copy REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  config.scoped_views = true

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  config.omniauth :developer, fields: [:name, :nickname, :email] if Rails.application.secrets.dig(:omniauth, :developer).present?
  if Rails.application.secrets.dig(:omniauth, :facebook).present?
    config.omniauth :facebook,
                    Rails.application.secrets.omniauth[:facebook][:app_id],
                    Rails.application.secrets.omniauth[:facebook][:app_secret],
                    scope: :email,
                    info_fields: "name,email,verified"
  end
  if Rails.application.secrets.dig(:omniauth, :twitter).present?
    config.omniauth :twitter,
                    Rails.application.secrets.omniauth[:twitter][:api_key],
                    Rails.application.secrets.omniauth[:twitter][:api_secret]
  end
  if Rails.application.secrets.dig(:omniauth, :google_oauth2).present?
    config.omniauth :google_oauth2,
                    Rails.application.secrets.omniauth[:google_oauth2][:client_id],
                    Rails.application.secrets.omniauth[:google_oauth2][:client_secret]
  end

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.failure_app = Decidim::DeviseFailureApp
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :decidim
  #
  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'
end
