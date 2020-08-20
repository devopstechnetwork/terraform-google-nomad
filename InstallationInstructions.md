# These are the installation instructions

1. Create packer images by following instructions in [examples/nomad-consul-image](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/nomad-consul-image)
2. Use Terraform to deploy Consul and Nomad in the same cluster by following instructions in [examples/root-example](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/root-example)


# Additional Notes

This instruqt track was very helpful
https://play.instruqt.com/hashicorp/tracks/nomad-consul-connect

The link below is very important to set up Nomad with Consul Connect
https://www.nomadproject.io/docs/integrations/consul-connect/

## How to access a remote Nomad cluster:
You need to define the following env variables:
```shell
export NOMAD_ADDR=https://remote-address:4646
# You need this if you're using ACls in the Nomad cluster
export NOMAD_TOKEN=<token>
```

## Things needed that are not included in this deployment
- Docker installed on all client nodes to show up as a docker driver in Nomad
- Consul Servers and Consul Clients need to both have the following in the consul config under `/opt/consul/config/default.json`:

```json
  "connect": {
	  "enabled": true
  },
  "ports": {
	  "grpc": 8502
  },
```

- Consul clients and servers need the following acl stanza to enable acls good guide: https://learn.hashicorp.com/consul/security-networking/production-acls#apply-individual-tokens-to-the-services:
in JSON:
```json  
  "acl": {
    "enabled": true,
    "default_policy": "deny",
    "enable_token_persistence": true
    }
```
in HCL:
```
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
```



- Nomad needs CNI plugins, use the below to install it:
```shell
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.4/cni-plugins-linux-amd64-v0.8.4.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
```

- Nomad Host Volumes:
Nomad host volumes can manage storage for stateful workloads running inside a Nomad cluster. In my app, I used host volumes as per this guide. Nomad also supports Container Storage Interface (CSI), however, it's currently in Beta as of the time of writing this blog post. The configuration needed on the Nomad client for enabling a host volume is found below:

```shell
client {
  enabled = true
  host_volume "mongodb" {
    path      = "/opt/mongodb/data"
    read_only = false
  }
}
```

- Nomad Servers need a Vault config in `/opt/nomad/config/default.json`. I used the root vault token for ease:
```shell
vault {
  enabled = true
  address = "http://vault.hashidemos.tekanaid.com:8200"
  token = "xxxxx" 
}
```

- Nomad Clients need a Vault config:
```shell
vault {
  enabled = true
  address = "http://vault.hashidemos.tekanaid.com:8200"
}
```

- Nomad servers and clients need to have the acl stanza and a few other things according to https://learn.hashicorp.com/nomad/acls/bootstrap
```shell
acl {
  enabled = true
}
```
This guide helps to create a specific policy for an app developer to deploy jobs. I tried this with Terraform, but didn't work because I believe Terraform is doing accessing other end points so it's easier to use a manager token. However, below are the steps if you want to create policies for app developers. You can find the tokens in 1password under webblog-nomad secret
https://learn.hashicorp.com/nomad/acls/create_policy

Here are the steps:
1. Save the policy below to a file called `app-dev.policy.hcl` I commented out the capabilities and replaced `policy = read` with `policy = write` because I don't konw what Terraform is doing exactly as the TF apply was failing do to permission issues and I didn't have the time to figure out which capabilites are needed so I put `write` as a coarse-grained 
```shell
namespace "default" {
  policy = "write"
}
```

2. Apply the policy
```shell
nomad acl policy apply -description "Application Developer policy" app-dev app-dev.policy.hcl
```

3. Create the token
```shell
nomad acl token create -name="Test app-dev token" -policy=app-dev -type=client | tee app-dev.token
```

- This is a good guide to follow for Consul ACLs to work with Nomad...Note that for Consul Connect you need to explicitly define Intentions when Consul ACLs are enabled. Otherwise services don't talk to each other.
https://learn.hashicorp.com/nomad/consul-integration/nomad-connect-acl

- Pay attention to extra firewall ports in GCP that will need to be opened in GCP. Below is a list for applications specifically

tcp:8080
tcp:8081
tcp:9002
tcp:8000
tcp:27017 to allow mongodb to be accessed by Vault
tcp:8001
tcp:8002
tcp:8003
tcp:8004
tcp:8005

## Troubleshooting

Good guide:
https://learn.hashicorp.com/nomad/managing-jobs/inspecting-state

## Nomad Client Config File
sam@samg-nomad-client-cluster-zndq:/opt/nomad/config$ cat default.hcl
datacenter = "us-central1-f"
name       = "samg-nomad-client-cluster-zndq"
region     = "us-central1"
bind_addr  = "0.0.0.0"

advertise {
  http = "10.128.0.17"
  rpc  = "10.128.0.17"
  serf = "10.128.0.17"
}

client {
  enabled = true
  host_volume "mongodb" {
    path      = "/opt/mongodb/data"
    read_only = false
  }
}

consul {
  address = "127.0.0.1:8500"
  token   = "5b998ee9-3c47-a97e-4652-a397364482bc"
}

vault {
  enabled = true
  address = "http://vault.hashidemos.tekanaid.com:8200"
}

acl {
  enabled = true
}

## Consul Client Config File

sam@samg-nomad-client-cluster-zndq:/opt/consul/config$ cat default.json
{
  "advertise_addr": "10.128.0.17",
  "bind_addr": "10.128.0.17",

  "client_addr": "0.0.0.0",
  "datacenter": "us-central1",
  "node_name": "samg-nomad-client-cluster-zndq",
  "retry_join": ["provider=gce project_name=sam-gabrail-gcp-demos tag_value=samg-nomad-server-cluster"],
  "server": false,
  "autopilot": {
  "cleanup_dead_servers": true,
  "last_contact_threshold": "200ms",
  "max_trailing_logs": 250,
  "server_stabilization_time": "10s",
  "redundancy_zone_tag": "az",
  "disable_upgrade_migration": false,
  "upgrade_version_tag": ""
},
  "ui": true,
  "connect": {
	  "enabled": true
  },
  "ports": {
	  "grpc": 8502
  },

  "raft_protocol": 3,
  "acl": {
    "enabled": true,
    "default_policy": "deny",
    "enable_token_persistence": true
    }
}

## Nomad Server Config File

sam@samg-nomad-server-cluster-41g9:/opt/nomad/config$ cat default.hcl
datacenter = "us-central1-f"
name       = "samg-nomad-server-cluster-41g9"
region     = "us-central1"
bind_addr  = "0.0.0.0"

advertise {
  http = "10.128.0.16"
  rpc  = "10.128.0.16"
  serf = "10.128.0.16"
}

server {
  enabled = true
  bootstrap_expect = 1
}

consul {
  address = "127.0.0.1:8500"
  token   = "XXXXX"
}

vault {
  enabled = true
  address = "http://vault.hashidemos.tekanaid.com:8200"
  token = "XXXXX"
}

acl {
  enabled = true
}

## Consul Server Config File

sam@samg-nomad-server-cluster-41g9:/opt/consul/config$ cat default.json
{
  "advertise_addr": "10.128.0.16",
  "bind_addr": "10.128.0.16",
  "bootstrap_expect": 1,
  "client_addr": "0.0.0.0",
  "datacenter": "us-central1",
  "node_name": "samg-nomad-server-cluster-41g9",
  "retry_join": ["provider=gce project_name=sam-gabrail-gcp-demos tag_value=samg-nomad-server-cluster"],
  "server": true,
  "autopilot": {
  "cleanup_dead_servers": true,
  "last_contact_threshold": "200ms",
  "max_trailing_logs": 250,
  "server_stabilization_time": "10s",
  "redundancy_zone_tag": "az",
  "disable_upgrade_migration": false,
  "upgrade_version_tag": ""
},
  "ui": true,
  "connect": {
	  "enabled": true
  },
  "ports": {
	  "grpc": 8502
  },

  "raft_protocol": 3,
  "acl": {
    "enabled": true,
    "default_policy": "deny",
    "enable_token_persistence": true
    }
}