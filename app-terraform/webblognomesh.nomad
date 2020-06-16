job "webblognomesh" {
  datacenters = ["us-central1-f"]

  group "webblogGroup" {

    volume "mongodb" {
      type      = "host"
      read_only = false
      source    = "mongodb"
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
        "MONGO_INITDB_ROOT_PASSWORD" = "GGhJxUpAB23"
      }

      config {
        image = "mongo:4.2.7"
        port_map {
          mongo = 27017
        }
      }

      resources {
        network {
          port "mongo" {
            static = 27017
          }
        }
      }

      service {
        name = "mongodb"
        port = "mongo"
      }      

    }

    task "frontendTask" {
      driver = "docker"
      
      env {
        DB_SERVER = "${NOMAD_IP_mongoTask_mongo}"
        DB_PORT = "${NOMAD_PORT_mongoTask_mongo}"
      }

      config {
        image = "samgabrail/webblog-nomad-demo:latest"
        port_map {
          http = 8001
        }
      }

      resources {
        network {
          port "http" {
            static = 8000
          }
        }
      }

      service {
        name = "frontend"
        port = "http"
      }

      vault {
        policies = ["webblog"]
      }


    }
  }
}