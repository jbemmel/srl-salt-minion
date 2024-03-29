proxy:
  proxytype: nornir

hosts:
  SRL1:
    hostname: 172.20.20.21
    platform: nokia_srl
    groups: [lab]
    connection_options:
     pygnmi:
      port: 57400
      extras:
       path_cert: "/home/salt/srl1.pem"
  SRL2:
    hostname: 172.20.20.22
    platform: nokia_srl
    groups: [lab]
    connection_options:
     pygnmi:
      port: 57400
      extras:
       path_cert: "/home/salt/srl2.pem"

groups:
  lab:
    username: admin
    password: admin
    connection_options:
      netmiko:
        extras:
          device_type: nokia_srl
      pygnmi:
        port: 57400
        # extras:
        #  path_cert: "/home/salt/data/keys/root-ca.pem"
        #  skip_verify: True
      scrapli:
        platform: nokia_srlinux # requires pip install scrapli-community
        port: 22
        extras:
          transport: system # or asyncssh, ssh2, paramiko
          auth_strict_key: false
          ssh_config_file: false
      napalm:
        platform: srl
        extras:
          optional_args:
            auto_probe: 0
            config_private: False

defaults: {}