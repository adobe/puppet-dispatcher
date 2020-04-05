# Dispatcher
[description]: #description
[setup]: #setup
[affects]: #what-the-dispatcher-module-affects
[requirements]: #setup-requirements
[beginning]: #beginning-with-dispatcher
[usage]: #usage

[dispatcher configuration]: #dispatcher-configuration
[farm definition]: #defining-a-farm
[farm security]: #securing-a-farm

[PDK]: https://puppet.com/docs/pdk/1.x/pdk.html
[PDK Validation]: https://puppet.com/docs/pdk/1.x/pdk_testing.html#validating
[PDK Unit Testing]: https://puppet.com/docs/pdk/1.x/pdk_testing.html#testing-validating

[Facter]: http://docs.puppet.com/facter/
[puppet module]: https://puppet.com/docs/puppet/latest/modules_fundamentals.html
[Apache module]: https://forge.puppet.com/puppetlabs/apache

[dispatcher]: https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/dispatcher.html
[Dispatcher module]: https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html

[`dispatcher`]: REFERENCE.md#dispatcher
[`dispatcher::farm`]: REFERENCE.md#dispatcherfarm
[`Dispatcher::Farm::Renderer`]: REFERENCE.md#dispatcherfarmrenderer
[`Dispatcher::Farm::Filter`]: REFERENCE.md#dispatcherfarmfilter
[`Dispatcher::Farm::Cache`]: REFERENCE.md#dispatcherfarmcache

[REFERENCE.md]: REFERENCE.md
[metadata.json]: metadata.json
[Contributing]: .github/CONTRIBUTING.md



#### Table of Contents

1. [Description][Description]
2. [Setup - The basics of getting started with dispatcher][setup]
    * [What dispatcher affects][affects]
    * [Setup requirements][requirements]
    * [Beginning with dispatcher][beginning]
3. [Usage - Configuration options and additional functionality][usage]
    * [Dispatcher Configuration][dispatcher configuration]
    * [Defining a Farm][farm definition]
    * [Securing a Farm][farm security]
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Contributing - Guidelines for contributing](#contributing)
6. [Development - Guide for contributing to the module](#development)


## Description

[Dispatcher][] is Adobe Experience Manager's caching and/or load balancing tool. This [Puppet module][] will facilitate the configuration and management of Adobe Dispatcher modules in your infrastructure. It can configure the module and any number of farms definitions in an a simple and efficient manner.

## Setup

### What the Dispatcher module affects:

* Dispatcher module configuration files
* Dispatcher farm configuration files

### Setup Requirements

Because the dispatcher module depends on the [Apache module][], that module must be included in the catalog, otherwise an error will be raised.

This module will configure the dispatcher, but the module must be provided by the consumer. Ensure that the [Dispatcher module][] is made available within the catalog.

### Beginning with Dispatcher

To have Puppet install the Dispatcher with default parameters (but no farms), declare the dispatcher class:

```puppet
class { 'dispatcher' :
  module_file => '/path/to/module/file.so'
}
```  

When you declare this class with the default options, the module:

* Installs the module in the operating system dependent Apache installation directory.
* Places the dispatcher configuration file in the operating system dependent Apache directory.
* Configures the module with default log file, log level, and other optional flags.

> **Note**: While the dispatcher module does not require any farms to be defined, the system will not function correctly without any - and none are defined/provided by default.

## Usage

### Dispatcher Configuration

The default parameters for the [`dispatcher`][] class configures the Dispatcher module with reasonable defaults to ensure operation.  Minimally, a reference to the dispatcher module file must be provided by the consumer.

```puppet
class { 'dispatcher' :
  module_file => '/path/to/module/file.so'
}
```

See the [`dispatcher`][] class reference for a list of all parameters and their defaults.

#### Specifying Farms to Load from Hiera

The `dispatcher` class can be passed a list of farm names. These will signal to load farms directly from hiera data, so that no other resources need to be defined.

```puppet
class { 'dispatcher' :
  module_file => '/path/to/module/file.so',
  farms       => ['author', 'publish'],
}
```

#### Dispatcher Loading to VirtualHosts 

To automatically load the Dispatcher module into Apache Virutal hosts, the `dispatcher` class can be passed a list of those virtual host names. This will concatenate the necessary fragment into the VirtualHost conf file to allow for the dispatcher to process requests.

```puppet
class { 'dispatcher' :
  module_file => '/path/to/module/file.so',
  vhosts       => ['default', 'custom'],
}
```

### Defining a Farm

The [`dispatcher::farm`] configures a render farm definition for the Dispatcher. A minimal configuration is required for successful operation - these parameters are `renderers`, `filters`, and `cache`.

```puppet
dispatcher::farm { 'publish' :
  renderers => [
    { hostname => 'localhost', port => 4502 },
  ],
  filters => [
    {
      allow => false,
      rank  => 1,
      url   => { regex => true, pattern => '.*' },
    },
  ],
  cache => {
    docroot => '/var/www/html',
    rules => [
      { rank => 1, glob => '*.html', allow => true },
    ],
    allowed_clients => [
      { rank => 1, glob => '*', allow => false },
      { rank => 2, glob => '127.0.0.1', allow => true },
    ],
  }
}
```

See the [`dispatcher::farm`][] defined type reference for a list of all parameters and their defaults.

> **Note**: It is recommended that the farms be defined using hiera data rather than define them as in-line resources in the catalog. See the examples or spec data for ways to achieve this.

#### Required Parameters

##### Renderers

The `renderers` parameter must be passed a list of [`Dispatcher::Farm::Renderer`][] struct types. This struct allows the farm to be configured with one or more renderer endpoints.

```puppet
dispatcher::farm { 'publish' :
...
  renderers => [
    { hostname => '192.168.0.1', port => 4502 },
    { hostname => '192.168.0.1', port => 4502 },
  ],
...
}
```

See the [`Dispatcher::Farm::Renderer`][] struct type reference for a list of all parameters.

##### Filters

The `filters` parameter must be passed a list of [`Dispatcher::Farm::Filter`][] struct types. This struct defines the order and rules for allowing content to be accessible via the Dispatcher.

Since Adobe has recommended not using **glob** references, they are not supported in Filters. Regex support is available - this flag is used to determine the quote type: `'` (regex) or `"` (normal).

This example has two rules:
 * Deny access to all content
 * Allows `html` files from the `/content` path

They will be ordered **deny** then **allow**, as the rank attribute determines order.

```puppet
dispatcher::farm { 'publish' :
...
  filters => [
    {
      'allow' => true,
      'rank' => 10,
      'path' => { 'regex' => false, 'pattern' => '/content/*' },
      'extension' => { 'regex' => false, 'pattern' => 'html' },
    },
    { 'allow' => false, 'rank' => 1, 'url' => { 'regex' => true, 'pattern' => '.*' } },
  ],
...
}
```

See the [`Dispatcher::Farm::Filter`][] struct type reference for a list of all parameters.

##### Cache

The `cache` parameter must be passed a [`Dispatcher::Farm::Cache`][] struct type. This configures the rules for the farm's cache.

This example specifies a docroot, cache files with the `html` extension, and allow the local system to flush the cache.

```puppet
dispatcher::farm { 'publish' :
...
  cache => {
    docroot => '/var/www/html',
    rules => [
      { rank => 1, glob => '*.html', allow => true },
    ],
    allowed_clients => [
      { rank => 1, glob => '*', allow => false },
      { rank => 2, glob => '127.0.0.1', allow => true },
    ],
  }
...
}
```

See the [`Dispatcher::Farm::Cache`][] struct type reference for a list of all parameters.

### Securing a Farm

The [`dispatcher::farm`][] defined type supports a custom parameter `secure` which will indicate whether or not to enable the Adobe Best Practices for securing a dispatcher. Enabling this flag will define the following Farm configurations:

#### Filters

First, block all access - This forces consumers to explicitly define access rights via other, subsequent filters. Regardless of other filters defined, this will always be the first one.

```
  /0000 { /type "deny" /url '.*' }
```

Finally, block access to specific AEM resource paths, selectors, URL parameters and source files. Again, regardless of other filters defined, these entries will always be at the end of the list. This will ensure that even if another filter grants access, these override other definitions.

> If access is needed to any resources blocked by these filters, then the Farm must be set to `secure => false`. There is no mechanism to override the order of these filters.

```
  /9993 { /type "deny" /url "/crx/*" }
  /9994 { /type "deny" /url "/system/*" }
  /9995 { /type "deny" /url "/apps/*" }
  /9996 { /type "deny" /selectors '(feed|rss|pages|languages|blueprint|infinity|tidy|sysview|docview|query|[0-9-]+|jcr:content)' /extension '(json|xml|html|feed)' }
  /9997 { /type "deny" /method "GET" /query "debug=*" }
  /9998 { /type "deny" /method "GET" /query "wcmmode=*" }
  /9999 { /type "deny" /extension "jsp" }
```

#### Cache

Adobe Security best practices recommend that only explicit agents be allowed to flush the Dispatcher's cache. Therefore enabling farm security defines the following `allowedClient` entry. Again, regardless of other definitions in the [`Dispatcher::Farm::Cache`][] struct, this entry will always be first - forcing consumers to be explicit about the allowed clients.

```
/cache {
  ...
  /allowedClients {
    /0000 { /type "deny" /glob "*" }
  }
}
```

### SELinux Docroot Support

Normally the Apache module is responsible for managing the *docroot* for a given farm and VirtualHost. However, when SELinux is enabled and enforcing, this creates an issue as the default setting for the *docroot* is read only.

This module allows you to switch ownership of the docroot from the Apache module to this module. Thus, when SELinux is enforcing, the `seltype` will be correctly set to read/write on this folder. To do so, set the `manage_docroot` of the `Dispatcher::Farm::Cache` struct to `true`. 

> **Note**: The [`manage_docroot`](https://github.com/puppetlabs/puppetlabs-apache/blob/master/REFERENCE.md#manage_docroot) of the Apache VirtualHost resource must be set to `false` or a catalog error will occur. 

```puppet
dispatcher::farm { 'publish' :
...
  cache => {
    docroot => '/var/www/html',
    manage_docroot => true,
    rules => [
      { rank => 1, glob => '*.html', allow => true },
    ],
    allowed_clients => [
      { rank => 1, glob => '*', allow => false },
      { rank => 2, glob => '127.0.0.1', allow => true },
    ],
  }
...
}
``` 

> **Note**: This module only supports managing the `docroot` based on default parameters in the Apache module. To customize further, the `docroot` must be managed externally.  

## Reference

For information on classes, types, and structs see the [REFERENCE.md][].

### Templates

This module relies heavily on templates to configure the [`dispatcher::farm`][] defined type. These templates are based on [Facter][] and properties in the [Apache module][] that are specific to your operating system. None of these templates are meant for configuration.

## Limitations

For an extensive list of supported operating systems, see the [metadata.json][].

## Contributing

We always appreciate any community contributions to this project. Please check out our [Contributing][] guidelines for more information.

## Development

### Testing

This module uses [PDK][] for development. When making updates to the module, please run the [PDK Validation][] and [PDK Unit Testing] commands.

```
  $ pdk validate
  ...
  $ pdk test unit --puppet-version 5
  ...
  $ pdk test unit --puppet-version 6
```

When developing or testing, it is recommended _not_ to use the `bundle` command directly. PDK and Bundle aren't always friendly. If a bundle command will be run, use PDK to "wrap" the bundle command. See the [Acceptance Tests](#acceptance-tests) section for example with running Litmus.

> **Note**: This module should be tested against both Puppet v5.x and v6.x

### Acceptance Tests

This module uses [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) to perform acceptance tests. There are three provision groups: `debian`, `ubuntu` and `el`. Before submitting a Pull Request, please add acceptance tests and validate the changes:
 
```
  $ pdk bundle exec rake 'litmus:provision_list[<group>]'
    ...
  $ pdk bundle exec rake litmus:install_agent
    ...
  $ pdk bundle exec rake litmus:install_module
    ...
  $ pdk bundle exec rake litmus:acceptance:parallel
    ...
  $ pdk bundle exec rake litmus:tear_down
```

### Documentation

If you submit a change to this module, be sure to regenerate the reference documentation as follows. (This may be removed after validation that it is created by TravisCI.)

```
$ pdk bundle exec rake strings:generate:reference
```
