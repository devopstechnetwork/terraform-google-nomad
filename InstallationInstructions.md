# These are the installation instructions

1. Create packer images by following instructions in [examples/nomad-consul-image](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/nomad-consul-image)
2. Use Terraform to deploy Consul and Nomad in the same cluster by following instructions in [examples/root-example](https://github.com/samgabrail/terraform-google-nomad/tree/master/examples/root-example)
3. Import the consul-gcp module into TFC and reference that in the `main.tf` file