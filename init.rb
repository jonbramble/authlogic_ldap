unless Rails.env.test? || Rails.env.home?
	require 'authlogic_ldap'
end
