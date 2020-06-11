provider "nomad" {
  address = "http://34.70.30.144:4646"
}

resource "nomad_job" "monitoring" {
  jobspec = "${file("${path.module}/webblogtraefik.nomad")}"
}

