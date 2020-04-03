# Statistics Farm Example

This example shows how to configure the farm for managing load balancing statistics.

```yaml
dispatcher::farm::publish::statistics_categories:
  -
    rank: 1
    name: 'html'
    glob: '*.html'
```
