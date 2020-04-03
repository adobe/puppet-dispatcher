# Custom Parameter Examples

This will install the Dispatcher module into Apache, but does not declare any Farms.

```puppet
  contain dispatcher
```

```yaml
dispatcher::module_file: '/path/to/dispatcher-module.so'
dispatcher::decline_root: false
dispatcher::log_file: '/custom/path/to/logfile.log'
dispatcher::log_level: 'debug'
dispatcher::pass_error: '400-411,413-417,500',
dispatcher::use_processed_url: false
dispatcher::keep_alive_timeout: 0
dispatcher::no_cannon_url: true
```