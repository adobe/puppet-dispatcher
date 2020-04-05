# Cache Auto Manage Docroot Farm Example

This example will configure the farm to manage the docroot instead of Apache's virtual host resource.

```yaml
dispatcher::farm::publish::cache:
  docroot: /path/to/docroot
  manage_docroot: true
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
