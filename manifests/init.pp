# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include dispatcher
class dispatcher {

  # Check for Apache because it is used by parameter defaults
  if ! defined(Class['apache']) {
    fail('You must include the Apache class before using any dispatcher class or resources.')
  }

}
