# Cache Auto Invalidate Farm Example

This example will configure the farm automatically invalidate html files on an activation.

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
  invalidate:
    -
      rank: 10
      glob: '*.html'
      allow: true

```