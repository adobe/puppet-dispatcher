# Cache Ignore URL Parameters Farm Example

Configure which URL parameters are ignored for caching purposes (e.g. for Analytics campaigns, or searching)

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
  ignore_url_params:
    -
      rank: 10
      glob: 'q'
      allow: true
```
