
# Cache Enable TTL Farm Example

This will enable the TTL flag for the farm, to configure for caching based on response headers.

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
  enable_ttl: true
```
}