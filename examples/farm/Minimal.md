# Minimal Parameters Farm Example

This example shows the minimal configuration required to configure a Farm.

```puppet
  contain dispatcher
```

```yaml
dispatcher::module_file: /path/to/dispatcher-module.so
dispatcher::farms:
  - publish

dispatcher::farm::publish::renderers:
  -
    hostname: localhost
    port: 4503
dispatcher::farm::publish::filters:
  -
    allow: false
    rank: 1
    url:
      regex: true
      pattern: '.*'
dispatcher::farm::publish::cache:
  docroot: /var/www/html/publish
  rules:
    -
      rank: 1
      glob: '*.html'
      allow: true
  allowed_clients:
    -
      rank: 1
      glob: '*'
      allow: false
    -
      rank: 2
      glob: '127.0.0.1'
      allow: true

```
