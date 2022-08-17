proxy:
  proxytype: nornir

hosts:
  SRL1:
    hostname: 172.20.20.21
    platform: nokia_srl
    groups: [lab]
  SRL2:
    hostname: 172.20.20.22
    platform: nokia_srl
    groups: [lab]

groups:
  lab:
    username: admin
    password: admin
    connection_options:
      scrapli:
        platform: nokia_srlinux # requires pip install scrapli-community
        port: 22
        extras:
          transport: system # or asyncssh, ssh2, paramiko
          auth_strict_key: false
          ssh_config_file: false
      napalm:
        platform: srlinux
        extras:
          optional_args:
            auto_probe: 0
            config_private: False

defaults: {}