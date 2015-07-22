DESCRIPTION
===========

Installs opendkim package and basically follows this: https://help.ubuntu.com/community/Postfix/DKIM

Installs Postfix via the official postfix cookbook and adds the following configuration:

    node.default['postfix']['main']['milter_default_action'] = 'accept'
    node.default['postfix']['main']['milter_protocol']       = 2
    node.default['postfix']['main']['smtpd_milters']         = node['postfix_dkim']['postfix_milter_socket']
    node.default['postfix']['main']['non_smtpd_milters']     = node['postfix_dkim']['postfix_milter_socket']

This has been tested on Ubuntu 10.04 and 14.04

ATTRIBUTES
==========

See `man 5 opendkim.conf` for more info on these:

* `postfix_dkim['domain']` - Domain to sign (default: your FQDN)
* `postfix_dkim['keyfile']` - Full path to location of private key. If it doesn't exist, will use dkim-genkey to make one for you. (default: /etc/mail/dkim.key)
* `postfix_dkim['selector']` - See the section on selectors http://dkim.org/info/dkim-faq.html (default: mail)
* `postfix_dkim['autorestart']` - Restart on failure (default: false). Should probably flip this to true when you're sure the filter works.
* `postfix_dkim['sender_headers']` - SenderHeaders value (default: nil, will use opendkim default). See opendkim manual for more info.

For /etc/default/opendkim:

  `postfix_dkim['socket']` - Socket to bind to. (default: 'inet:8891@localhost')

For key generation using key-genkey:

  `postfix_dkim['testmode']` - Run DKIM in test mode? see "t=" on http://www.dkim.org/specs/rfc4871-dkimbase.html#key-text (default: true)

For Postfix's main.cf:

  `postfix_dkim['postfix_milter_socket']` - Opendkim socket in Postfix format, see: http://www.postfix.org/MILTER_README.html#smtp-only-milters (default: 'inet:localhost:8891')
                                            This should mirror `postfix_dkim['socket']`

USAGE
=====

Set the attributes (defaults should work for most on Ubuntu), and it installs and configures postfix and the postfix filter (opendkim).

Will attempt to generate a private key for you, if it doesn't already exist (key file is specified in the postfix_dkim[:keyfile] attribute)

## Important
DKIM setup is not complete until you create the necessary TXT DNS record containing your public key, which is located in the `postfix_dkim[:selector]`.txt file within the `postfix_dkim[:keyfile]` directory.

So, if you're using defaults, this will be located in `/etc/mail/mail.txt`. You can safely delete or move this file once you've created the DNS record.