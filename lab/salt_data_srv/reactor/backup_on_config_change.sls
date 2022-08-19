Backup config upon file changed event:
  local.state.apply:
    - tgt: {{ data['id'] }}
    - arg:
        - backup_config