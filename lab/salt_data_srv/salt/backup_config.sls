{% set curtime = None | strftime("%Y-%m-%d-%H-%M-%S") %}
backup_config:
  cp.push:
    - path: /etc/opt/srlinux/config.json
    - upload_path: {{ grains['id'] }}-config-{{ curtime }}.json
