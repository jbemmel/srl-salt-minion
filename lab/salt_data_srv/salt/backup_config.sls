
# Note that this timestamp is relative to the master; there is a '_stamp' event parameter somewhere
{% set _stamp = None | strftime("%Y-%m-%d-%H-%M-%S") %}
backup_config:
  module.run:
    - name: cp.push
    - path: /etc/opt/srlinux/config.json
    - upload_path: {{ grains['id'] }}-config-{{ _stamp }}.json

