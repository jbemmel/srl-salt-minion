Backup config upon file changed event:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
        - backup_config

# Files end up under /var/cache/salt/master/minions/srl1/files/srl1-config-2022-08-19-21-43-34.json