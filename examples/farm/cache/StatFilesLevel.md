# Cache Stat Files Level Farm Example

Configure the stat file depth for invalidation.

```yaml
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
  statfileslevel: 3
```
