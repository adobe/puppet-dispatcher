# Session Management Farm Example

This example shows how to configure the session cache for the farm.

```yaml
dispatcher::farm::publish::sessionmanagement:
  directory: /path/to/sessions
  encode: sha1
  header: HTTP:authorization
  timeout: 90
```
