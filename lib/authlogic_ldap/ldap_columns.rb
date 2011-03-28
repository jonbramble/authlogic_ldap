module AuthlogicLdap
	module Session
		module LdapColumns

			#how can this be made super magic? so that you can tell it what to get from any ldap service

			def self.included(klass)
			klass.class_eval do
				Rails.logger.info "called class eval"
				extend Config     #extend is commonly used to mix instance methods of a module into a class
				include InstanceMethods
				before_save :update_info # validations for session
			end

			end

		module Config

     		

		end




		module InstanceMethods

		private	
			def update_info
				
				return if errors.count > 0
				ldap = Net::LDAP.new
          			ldap.host = ldap_host
          			ldap.port = ldap_port
				ldap.base = ldap_base
				
				ldap.authenticate ldap_user_dn, ldap_password

				if ldap.bind			
	ldap.search( :base => ldap_base, :filter => Net::LDAP::Filter.eq( "CN", ldap_login ) ) do |entry|

				#can i replace this with a hash of ARcolumns and LDAP name equivalents
				#some error handling require here
				record.phone = "#{entry.telephonenumber}"
				record.email =  "#{entry.mail}"
				record.displayname = "#{entry.displayname}"
				record.initials = "#{entry.initials}"
					end
				end
				
				# add error messages to base
			
			end

			def ldap_user_dn
				ldap_login+self.class.ldap_user_dn
			end


		end


		end

		
	end
end
