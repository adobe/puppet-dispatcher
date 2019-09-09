# Statistic attributes hash.
# @summary A hash of Statistic attributes.
#   Used to configure the `/statistics` parameter instance of a Farm.
#
type Dispatcher::Farm::StatisticsCategories = Struct[
  {
    rank => Integer[0],
    name => String,
    glob => String,
  }
]
