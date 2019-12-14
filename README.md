# Dispatcher
[description]: #description
[setup]: #setup
[dispatcher affects]: #what-the-dispatcher-module-affects
[setup requirements]: #setup-requirements
[Beginning With Dispatcher]: #beginning-with-dispatcher
[Usage]: #usage


[puppet module]: https://puppet.com/docs/puppet/latest/modules_fundamentals.html
[apache module]: https://forge.puppet.com/puppetlabs/apache

[dispatcher]: https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/dispatcher.html
[Dispatcher Module]: https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html
#### Table of Contents

1. [Description][Description]
2. [Setup - The basics of getting started with dispatcher][setup]
    * [What dispatcher affects][dispatcher affects]
    * [Setup requirements][setup requirements]
    * [Beginning with dispatcher][Beginning with Dispatcher]
3. [Usage - Configuration options and additional functionality][Usage]
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

[Dispatcher][] is Adobe Experience Manager's caching and/or load balancing tool. This [Puppet module][] will facilitate the configuration and management of Adobe Dispatcher modules in your infrastructure. It can configure the module and any number of farms definitions in an a simple and efficient manner.

## Setup

### What the Dispatcher module affects:

* Dispatcher module configuration files
* Dispatcher farm configuration files

### Setup Requirements

Because the dispatcher module depends on the [Apache module][], it must be included in the catalog, otherwise an error will be raised.

This module will configure the dispatcher, but the module must be provided by the consumer. Ensure that the [dispatcher module][] is made available within the catalog.

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

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.

## Generate docs:

```
puppet strings generate --format markdown
```

## Acceptance Tests:

* `bundle exec rake 'litmus:provision_list[debian]'`
* On Debian:
  * Maybe not needed if using WaffleImages: `bundle exec bolt command run 'apt-get install wget -y' --inventoryfile inventory.yaml --nodes=ssh_nodes` 
  * `bundle exec bolt command run 'apt-get remove -y openssl' --inventoryfile inventory.yaml --nodes=ssh_nodes`
  * `bundle exec bolt command run 'ln -sf "$(find /usr/lib/x86_64-linux-gnu -name "libssl.so*1.0*" -type f -print |sort -dr|head -1)" /usr/lib/x86_64-linux-gnu/libssl.so.10' --inventoryfile inventory.yaml --nodes=ssh_nodes`
  * `bundle exec bolt command run 'ln -sf "$(find /usr/lib/x86_64-linux-gnu -name "libcrypto.so*1.0*" -type f -print |sort -dr|head -1)" /usr/lib/x86_64-linux-gnu/libcrypto.so.10' --inventoryfile inventory.yaml --nodes=ssh_nodes`
  
* `bundle exec rake litmus:install_agent`
* `bundle exec rake litmus:install_module`
* `bundle exec rake litmus:acceptance:parallel`
