name             'chatsecure_rubdub'
maintainer       'Chris Ballinger'
maintainer_email 'chris@chatsecure.org'
license          'AGPLv3'
description      'Installs/Configures ChatSecure RubDub XMPP PubSub Node'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe "chatsecure_rubdub", "Setup RubDub XMPP PubSub application"

# TODO: Document attributes

depends "ssh_known_hosts"
depends "nodejs"