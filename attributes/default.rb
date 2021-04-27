# /etc/opendkim.conf
default['postfix_dkim']['domain'] = node['fqdn']
default['postfix_dkim']['keyfile'] = '/etc/mail/dkim.key'
default['postfix_dkim']['selector'] = 'mail'

# /etc/default/opendkim
default['postfix_dkim']['socket'] = 'inet:8891@localhost' # Ubuntu default - listen on loopback on port 8891

# key generation
default['postfix_dkim']['testmode'] = true # Running in test mode - see "t=" on http://www.dkim.org/specs/rfc4871-dkimbase.html#key-text

# Postfix's main.cf
default['postfix_dkim']['postfix_milter_socket'] = 'inet:localhost:8891'
