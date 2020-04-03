# Custom Filters Farm Example

This example shows how to specify additional `filters` for a farm. Filters are a required parameter, the default example blocks all traffic, this example then allows **html** files in the */content* path.

```yaml
dispatcher::farm::publish::filters:
  -
    allow: false
    rank: 1
    url:
      regex: true
      pattern: '.*'
  -
    allow: true
    rank: 10
    path:
      regex: false
      pattern: '/content/*'
    extension:
      regex: false
      pattern: '.html'
```