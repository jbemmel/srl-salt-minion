# srl-salt-minion
SR Linux agent that configures and starts a Salt Minion process

## Minimal integration
This example provides a minimal but functional integration between SR Linux and Salt. It consists of a simple Python program that receives the Master address through the NDK,
and then starts the standard salt-minion script with a custom configuration file.

While it may be possible to do a "pure Python" integration, the additional complexity and devitation from the open source project base seems unnecessary. 

## Demo scenario
In the 'lab' directory:
```
make -C..
sudo clab deploy -t srl-salt-agent.clab.yml --reconfigure
```

Login to srl1 to enable the Salt Minion (this would typically be part of the standard config):
```
ssh admin@clab-srl-salt-agent-srl1
enter candidate
/srl-salty-minion-agent master 172.20.20.10
commit stay
```

Then login to the Salt master (which is configured to auto-accept all minions):
```
docker exec -it clab-srl-salt-agent-salt-master bash
salt-key -L
salt '*' test.ping
salt -G role:TOR test.version
salt 'srl*' cmd.run '/opt/srlinux/bin/sr_cli "show version"'
salt '*' cmd.run '/usr/local/bin/gnmic -u admin -p admin -a unix:///opt/srlinux/var/run/sr_gnmi_server --insecure -e json_ietf get --path /system/name'
salt 'srl1' cmd.run '/opt/srlinux/bin/sr_cli "tools system deploy-image /tmp/srlinux-22.6.1-281.bin reboot"'
salt srl1 cmd.script salt://templates/set_hostname2.j2 template=jinja args='{ hostname: jvb }'
```

### Access via Nornir proxy

It is possible to access SR Linux devices through a Nornir proxy:
```
salt proxy nr.cli "show version"
```

Likewise, a configuration template can be applied to all devices (or a subset):
```
salt proxy nr.cfg_gen filename=salt://templates/set_hostname.j2 plugin=netmiko  # test only
salt proxy nr.cfg filename=salt://templates/set_hostname.j2 plugin=netmiko
```

Lastly, gNMI can be used to retrieve or configure device settings:
```
salt proxy nr.gnmi get /system/name
```
Note that the above does not quite work yet; nornir-pygnmi module has limited debug output


## Resources:

* [Salt Minion library](https://github.com/saltstack/salt/blob/master/salt/minion.py) - instantiate a Minion object, provide location of its master
* [Salt Master Docker container](https://github.com/cdalvaro/docker-salt-master)
* [Nornir gNMI plugin for Salt](https://salt-nornir.readthedocs.io/en/latest/Nornir%20Execution%20Module.html#nr-gnmi)

One can find many "formulas", lots of empty ones too. Everything can be Salted

[FRR formula](https://github.com/saltstack-formulas/frr-formula)
