default_attributes(
  'nerve' => { 'enabled_services' => [ 'sqlslave','memcache' ] },
)

run_list(
  'apt', 'serf', 'ruby','demo', 'smartstack::nerve'
)
