# Prometheus monitoring and scalability of metrics retrieval

To address a specific use case involving scraping of port statistics through Prometheus, and performance concerns in case of large numbers of VLANs:

1. Deploy the lab with Salt and Prometheus exporter agent:
```
sudo clab deploy -t salt-with-prometheus.clab.yml --reconfigure
```

2. Use a Salt template to configure 2000 VLAN interfaces on SRL1
```
salt proxy nr.cfg filename=salt://templates/configure_2000_vlans.j2 plugin=netmiko NR=SRL1
```

3. Use wget to retrieve port statistics (mimmicking Prometheus scraping those metrics)
```
time wget -4 http://clab-srl-salt-agent-srl1:8888/metrics -O-
```
Note that the configured ACL is IPV4-only, hence '-4' to force the use of IPv4