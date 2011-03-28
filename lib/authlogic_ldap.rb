# AuthlogicLdap

puts "AuthlogicLdap"

require 'net/ldap'

require "authlogic_ldap/acts_as_authentic"
require "authlogic_ldap/session"
require "authlogic_ldap/ldap_columns"

ActiveRecord::Base.send(:include, AuthlogicLdap::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicLdap::Session)
Authlogic::Session::Base.send(:include, AuthlogicLdap::Session::LdapColumns)
