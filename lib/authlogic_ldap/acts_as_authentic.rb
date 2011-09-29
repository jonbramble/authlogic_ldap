# things to add to the way authlogic for the user, adds to active record

module AuthlogicLdap
	module ActsAsAuthentic
		def self.included(klass)
			klass.class_eval do
				extend Config     #extend is commonly used to mix instance methods of a module into a class
				add_acts_as_authentic_module(Methods, :prepend)
			end
		end


		module Config
			 
			 def validate_ldap_login(value = nil)			#set this in acts as auth block in user
        			rw_config(:validate_ldap_login, value, true)		
      			 end
      			 alias_method :validate_ldap_login=, :validate_ldap_login	


		end

		module Methods

			def self.included(klass)
        			klass.class_eval do
          				attr_accessor :ldap_password

					if validate_ldap_login
            					validates_uniqueness_of :ldap_login, :scope => validations_scope, :if => :using_ldap?
            					validates_presence_of :ldap_password, :if => :validate_ldap?
            					validate :validate_ldap, :if => :validate_ldap?
						
          				end
        			end
      			end


		

			def using_ldap?
        			respond_to?(:ldap_login) && respond_to?(:ldap_password) &&
          			(!ldap_login.blank? || !ldap_password.blank?)
      			end
        
			def validate_ldap
          		
				return if errors.count > 0
      
          			#ldap = Net::LDAP.new
          			#ldap.host = session_class.ldap_host
          			#ldap.port = session_class.ldap_port
          			#ldap.auth ldap_login, ldap_password
          			#errors.add_to_base(ldap.get_operation_result.message) if !ldap.bind
				return true
        		end
        private
        		def validate_ldap?
          			return ldap_login_changed? && !ldap_login.blank?
        		end

		end
	end
end
