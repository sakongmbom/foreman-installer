def postgresql_12_upgrade
  execute('foreman-maintain service start --only=postgresql')
  (_name, _owner, _enconding, collate, ctype, _privileges) = `runuser postgres -c 'psql -lt | grep -E "^\s+postgres"'`.chomp.split('|').map(&:strip)
  execute('foreman-maintain service stop')
  ensure_package('rh-postgresql12-postgresql-server', 'installed')

  if execute_command("rpm -q postgresql-contrib", false, false)
    ensure_package('rh-postgresql12-postgresql-contrib', 'installed')
  end

  execute(%(scl enable rh-postgresql12 "PGSETUP_INITDB_OPTIONS='--lc-collate=#{collate} --lc-ctype=#{ctype} --locale=#{collate}' postgresql-setup --upgrade"))
  ensure_package('postgresql-server', 'absent')
  ensure_package('postgresql', 'absent')
  execute('rm -f /etc/systemd/system/postgresql.service')
  ensure_package('rh-postgresql12-syspaths', 'installed')
end

if local_postgresql? && el7? && foreman_server? && needs_postgresql_scl_upgrade?
  postgresql_12_upgrade
end
