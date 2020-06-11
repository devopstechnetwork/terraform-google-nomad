job "countdash" {
  datacenters = ["us-central1-f"]

  group "countdash" {
    constraint {
      attribute = "${node.unique.name}"
      value = "samg-nomad-client-cluster-zndq"
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v1"
        port_map {
          "http" = 9001
        }
      }

      resources {
        cpu    = 100
        memory = 64

        network {
          port "http" {}
        }
      }

      service {
        name = "count-api"
        port = "http"
      }
    }

    task "dashboard" {
      driver = "docker"

      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_ADDR_web_http}"
      }

      config {
        image = "hashicorpnomad/counter-dashboard:v1"

        port_map {
          "http" = 9002
        }
      }

      resources {
        cpu    = 100
        memory = 64

        network {
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "count-dashboard"
        port = "http"
      }
    }
  }
}

