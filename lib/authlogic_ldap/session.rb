#things to do with the session, adds to authlogic::session:base

module AuthlogicLdap
	module Session
		def self.included(klass)	#called when included in another module or class
			klass.class_eval do
				extend Config     #extend is commonly used to mix instance methods of a module into a class
				include Methods
			end
		end

		module Config
		
		 	def ldap_host(value = nil)
        			rw_config(:ldap_host, value)
      			end
      			alias_method :ldap_host=, :ldap_host

			def ldap_port(value = nil)
        			rw_config(:ldap_port, value, 389)
     			end
			alias_method :ldap_port=, :ldap_port

			def ldap_base(value = nil)
        			rw_config(:ldap_base, value, "dc=com")
     			end
			alias_method :ldap_base=, :ldap_base

			# add validations for this
			def ldap_user_dn(value = nil)
				rw_config(:ldap_user_dn, value)
			end
			alias_method :ldap_user_dn=, :ldap_user_dn

			#not needed if not passing a new find method
			def find_by_ldap_login_method(value = nil)
        			rw_config(:find_by_ldap_login_method, value, :find_by_ldap_login)
      			end
      			alias_method :find_by_ldap_login_method=, :find_by_ldap_login_method

		end

		module Methods
			def self.included(klass)
        			klass.class_eval do
          				attr_accessor :ldap_login
          				attr_accessor :ldap_password

          				validate :validate_by_ldap, :if => :authenticating_with_ldap?	
        			end
      			end

			# Hooks into credentials to print out meaningful credentials for LDAP authentication.
      			def credentials
        			if authenticating_with_ldap?
          				details = {}
          				details[:ldap_login] = send(login_field)
          				details[:ldap_password] = "<protected>"
          				details
        			else
          				super
        			end
      			end
      
      			# Hooks into credentials so that you can pass an :ldap_login and :ldap_password key.
      			def credentials=(value)
        			super
        			values = value.is_a?(Array) ? value : [value]
        			hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        			if !hash.nil?
          				self.ldap_login = hash[:ldap_login] if hash.key?(:ldap_login)
          				self.ldap_password = hash[:ldap_password] if hash.key?(:ldap_password)
        			end
      			end	

private
			def validate_by_ldap

  errors.add(:ldap_login, I18n.t('error_messages.ldap_login_blank', :default => "can not be blank")) if ldap_login.blank?
  errors.add(:ldap_password, I18n.t('error_messages.ldap_password_blank', :default => "it can not be blank")) if ldap_password.blank?
				
          			return if errors.count > 0
				
				ldap = Net::LDAP.new
          			ldap.host = ldap_host
          			ldap.port = ldap_port
				ldap.base = ldap_base

          			ldap.authenticate ldap_user_dn, ldap_password
			   	if ldap.bind
            			#self.attempted_record = search_for_record(find_by_ldap_login_method, ldap_login)
					self.attempted_record = klass.send(find_by_ldap_login_method, ldap_login)
  errors.add(:ldap_login, I18n.t('error_messages.ldap_login_not_found', :default => "does not exist")) if attempted_record.blank?
          			else
  					errors[:base] << "#{ldap.get_operation_result.message}"

          			end
			end

        		def authenticating_with_ldap?
          			!ldap_host.blank? && (!ldap_login.blank? || !ldap_password.blank?)
        		end

			def ldap_host
          			self.class.ldap_host
        		end
        
        		def ldap_port
          			self.class.ldap_port	
        		end

			def ldap_base
          			self.class.ldap_base
        		end

			def ldap_user_dn
				ldap_login+self.class.ldap_user_dn
			end

			def find_by_ldap_login_method
				self.class.find_by_ldap_login_method
			end
		end
	end
end

	
		
	

	
