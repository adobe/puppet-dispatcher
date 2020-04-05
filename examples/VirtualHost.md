# Virtual Host Example

This example shows how to automatically load the Dispatcher module into two Apache Virutal hosts.

```puppet
  contain dispatcher
```

```yaml
dispatcher::module_file: /path/to/dispatcher-module.so
dispatcher::vhosts:
  - default
  - custom
```
