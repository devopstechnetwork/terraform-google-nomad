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

- Pay attention to extra firewall ports in GCP that will need to be opened in GCP. Below is a list for applications specifically
tcp:8080
tcp:9002
tcp:8000
tcp:27017 to allow mongodb to be accessed by Vault

## Troubleshooting

Good guide:
https://learn.hashicorp.com/nomad/managing-jobs/inspecting-state

