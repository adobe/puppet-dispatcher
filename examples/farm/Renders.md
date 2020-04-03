# Addtional Renders Farm Example

This example shows how to specify additional `renderers` for a farm. Renderers are a required parameter, the default example shows only one renderer, this example shows multiple renderers, with and additional flag.

```yaml
dispatcher::farm::publish::renderers:
  -
    hostname: 192.168.0.1
    port: 4503
    timeout: 60000  # Wait one minute
  -
    hostname: 192.168.0.2
    port: 4505
    timeout: 60000  # Wait one minute
```
