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
- Consul Servers and Consul Clients need to both have the following in the consul config:

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

## Troubleshooting

Good guide:
https://learn.hashicorp.com/nomad/managing-jobs/inspecting-state

sudo docker run --rm -d -e MONGODB_USERNAME=sam -e MONGODB_ROOT_PASSWORD=abcd1234 -e MONGODB_PASSWORD=abcd1234 -e MONGODB_DATABASE=webblog -v /opt/mongodb/data:/bitnami/mongodb bitnami/mongodb:4.2.3-debian-10-r10

sudo docker run --rm -d -e MONGODB_USERNAME=sam -e MONGODB_ROOT_PASSWORD=abcd1234 -e MONGODB_PASSWORD=abcd1234 -e MONGODB_DATABASE=webblog bitnami/mongodb:4.2.3-debian-10-r10

sudo docker run --rm -it -e MONGODB_USERNAME=sam -e MONGODB_ROOT_PASSWORD=abcd1234 -e MONGODB_PASSWORD=abcd1234 -e MONGODB_DATABASE=webblog -v /home/sam/mongodb:/bitnami/mongodb bitnami/mongodb:3.6-debian-10

sudo docker run --rm -d -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=abcd1234 -v /home/sam/mongodb:/data/db mongo



mongo --host "127.0.0.1" --port "27017" --authenticationDatabase admin -u root -p 
