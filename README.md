# chatsecure-rubdub-cookbook

Installs and configures the ChatSecure RubDub XMPP PubSub application as a persistent service.

## Requirements

This cookbook currently requires Ubuntu, as the service is configured for Upstart. 
This cookbook assumes that the service user's home directory resides at `/home/<username>`.
This cookbook's ssh credential pinning assumes the application will be served from Github.

### Platforms

- Ubuntu

### Chef

- Chef 12.0 or later

### Cookbooks

- `ssh_known_hosts` - pin the credentials of Github.com where code is checked out from
- `nodejs` - Install node and npm. TODO : Current design doesn't actually require this module

## Attributes

See `./attributes/defaults.rb`

## Usage

Include `chatsecure_rubdub` in your node's `run_list` after some recipe that installs and configures nodejs and npm to your liking. 

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[nodejs::npm]"
    "recipe[chatsecure_rubdub]"
  ]
}
```

## License

License: AGPLv3

