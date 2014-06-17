default_attributes(
  'nerve' => { 'enabled_services' => [ 'sqlslave','memcache' ] },
)

run_list(
  'serf', 'ruby','demo', 'smartstack::nerve'
)
