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
