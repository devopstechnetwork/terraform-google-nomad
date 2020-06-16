provider "nomad" {
  address = "http://34.70.30.144:4646"
}

// resource "nomad_job" "traefik" {
//   jobspec = file("${path.module}/webblogtraefik.nomad")
// }

// resource "nomad_job" "webblogconsulconnect" {
//   jobspec = file("${path.module}/webblogconsulconnect.nomad")
// }