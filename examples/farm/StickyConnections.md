# Sticky Connections Farm Examples

These examples show how to configure sticky connections for either one path, or multiple paths.

##  Single Path Example

```yaml
dispatcher::farm::publish::sticky_connections: /products
```

## Multiple Paths Example

```yaml
dispatcher::farm::publish::sticky_connections:
  paths:
    - /products
    - /this
    - /that
  domain: example.com
  http_only: true
  secure: true
```
