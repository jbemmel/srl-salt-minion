/system gnmi-server unix-socket admin-state enable
/acl cpm-filter ipv4-filter entry 345 {
		description "Allow communication from Minion to Salt-master"
        action {
            accept {
            }
        }
        match {
            protocol tcp
            destination-port {
                range {
                    start 4505
                    end 4506
                }
            }
        }
    }

/acl cpm-filter ipv4-filter entry 346 {
		description "Allow communication between Salt-master and Minion"
        action {
            accept {
            }
        }
        match {
            protocol tcp
            source-port {
                range {
                    start 4505
                    end 4506
                }
            }
        }
    }

/srl-salty-minion-agent master 172.20.20.10

/acl cpm-filter ipv4-filter entry 347 {
        description "Allow access to HTTP port via IPv4"
        action {
            accept {
            }
        }
        match {
            protocol tcp
            destination-port {
                value 8888
            }
        }
    }

/acl cpm-filter ipv4-filter entry 348 {
        description "Allow access from HTTP port via IPv4"
        action {
            accept {
            }
        }
        match {
            protocol tcp
            source-port {
                value 8888
            }
        }
    }

/system prometheus-exporter
    address ::
    port 8888
    network-instance mgmt
    http-path "/metrics"
    admin-state enable
    metric interfaces {
        state enable
        help-text "SRLinux generated metric"
    }
    metric subinterfaces {
        state enable
        help-text "SRLinux generated metric for subinterfaces"
    }