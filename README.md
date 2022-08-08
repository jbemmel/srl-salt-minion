# srl-salt-minion
SR Linux agent that configures and starts a Salt Minion process

## Minimal integration
This example provides a minimal but functional integration between SR Linux and Salt. It consists of a simple Python program that receives the Master address through the NDK,
and then starts the standard salt-minion script with a custom configuration file.

While it may be possible to do a "pure Python" integration, the additional complexity and devitation from the open source project base seems unnescessary. 

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
salt '*' test.version
```
## Resources:

* [Salt Minion library](https://github.com/saltstack/salt/blob/master/salt/minion.py) - instantiate a Minion object, provide location of its master
* [Salt Master Docker container](https://github.com/cdalvaro/docker-salt-master)
* [Nornir gNMI plugin for Salt](https://salt-nornir.readthedocs.io/en/latest/Nornir%20Execution%20Module.html#nr-gnmi)

One can find many "formulas", lots of empty ones too. Everything can be Salted

[FRR formula](https://github.com/saltstack-formulas/frr-formula)
