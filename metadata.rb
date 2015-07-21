name             "postfix-dkim"
maintainer       "Room 118 Solutions, Inc."
maintainer_email "info@room118solutions.com"
license          "Apache 2.0"
description      "Installs/Configures postfix and opendkim, a postfix DKIM filter (see: https://help.ubuntu.com/community/Postfix/DKIM)"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.3"
depends          'postfix', '> 3.0.0'
issues_url       "https://github.com/room118solutions/chef-postfix-dkim/issues"
source_url       "https://github.com/room118solutions/chef-postfix-dkim"