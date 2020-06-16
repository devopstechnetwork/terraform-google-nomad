# These are the installation instructions

1. Create packer images by following instructions in [examples/nomad-consul-image](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/nomad-consul-image)
2. Use Terraform to deploy Consul and Nomad in the same cluster by following instructions in [examples/root-example](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/root-example)
3. Import the consul-gcp module into TFC and reference that in the `main.tf` file

# Additional Notes

This instruqt track was very helpful
https://play.instruqt.com/hashicorp/tracks/nomad-consul-connect

The link below is very important to set up Nomad with Consul Connect
https://www.nomadproject.io/docs/integrations/consul-connect/

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

- Nomad needs CNI plugins, use the below to install it:
```shell
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.4/cni-plugins-linux-amd64-v0.8.4.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
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
1. Save the policy below to a file called `app-dev.policy.hcl` I commented out the capabilities and replaced `police = read` with `policy = write` because I don't konw what Terraform is doing exactly as the TF apply was failing do to permission issues and I didn't have the time to figure out which capabilites are needed so I put `write` as a coarse-grained 
```shell
namespace "default" {
  policy = "read"
  capabilities = ["submit-job","dispatch-job","read-logs"]
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

