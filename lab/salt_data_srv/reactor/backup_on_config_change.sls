Backup config upon file changed event:
  local.state.apply:
    - tgt: {{ data['hostname'] }}
    - arg:
        - backup_config