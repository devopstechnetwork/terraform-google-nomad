job "webblog" {
  datacenters = ["us-central1-f"]

  group "mongoGroup" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "mongodb" {
      type      = "host"
      read_only = false
      source    = "mongodb"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    service {
      name = "mongodb"
      port = "27017"

      connect {
        sidecar_service {}
      }
    }

    task "mongoTask" {
      driver = "docker"

      volume_mount {
        volume      = "mongodb"
        destination = "/data/db"
        read_only   = false
      }

      env = {
        "MONGO_INITDB_ROOT_USERNAME" = "root",
        "MONGO_INITDB_ROOT_PASSWORD" = "abcd1234"
      }

      config {
        image = "mongo:4.2.7"
      }

    //   resources {
    //     cpu    = 100
    //     memory = 64
    //   }
    }
  }

  group "frontendGroup" {

    network {
      mode = "bridge"
      port "http" {
        static = 8000
        to = 80
      }
    }

    service {
      name = "frontend"
      port = "80"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mongodb"
              local_bind_port = 8090
            }
          }
        }
      }
    }

    task "frontendTask" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/public-projects3/web-blog-demo:876ec7bf"
      }

    //   resources {
    //     cpu    = 100
    //     memory = 64
    //   }
    }
  }
}