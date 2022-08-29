# Prometheus monitoring and scalability of metrics retrieval

To address a specific use case involving scraping of port statistics through Prometheus, and performance concerns in case of large numbers of VLANs:

1. Deploy the lab with Salt and Prometheus exporter agent (built from https://github.com/jbemmel/srl-prometheus-exporter):
```
sudo clab deploy -t salt-with-prometheus.clab.yml --reconfigure
```

2. Use a Salt template to configure 1024 routed VLAN interfaces on SRL1
```
docker exec -it clab-srl-salt-agent-salt-master bash
salt proxy nr.cfg filename=salt://templates/configure_1024_vlans.j2 plugin=netmiko FB=SRL1 --async
```
Note that 'async' is used to avoid timeouts

3. Use wget to retrieve port statistics (mimmicking Prometheus scraping those metrics)
```
time wget -4 -q http://clab-srl-salt-agent-srl1:8888/metrics -O-
```
Note that the configured ACL is IPV4-only, hence '-4' to force the use of IPv4

Output for 1024 routed vlans:
```
...
subinterfaces_out_packets{interface_name="ethernet-1/1",subinterface_index="998"} 0
subinterfaces_out_packets{interface_name="ethernet-1/1",subinterface_index="999"} 0
subinterfaces_out_packets{interface_name="mgmt0",subinterface_index="0"} 147666

real	0m0.593s
user	0m0.004s
sys	0m0.017s
```

Output for 4094 bridged vlans templates/configure_4094_vlans.j2:
```
...
subinterfaces_out_packets{interface_name="ethernet-1/1",subinterface_index="998"} 0
subinterfaces_out_packets{interface_name="ethernet-1/1",subinterface_index="999"} 0
subinterfaces_out_packets{interface_name="mgmt0",subinterface_index="0"} 126765

real	0m3.700s
user	0m0.000s
sys	0m0.082s
```