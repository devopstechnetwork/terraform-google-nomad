job "webblogconsulconnect" {
  datacenters = ["us-central1-f"]

  group "webblogmongogroup" {
    network {
      mode = "bridge"
      // we only need the 3 lines below to expose mongo to the Internet so that Vault can create dynamic DB secrets by connecting to Mongo. Here we're exposing the host port of 27017 and directing traffic to the mongodb service listening on 27017. We're not using the service mesh. We should explore using an ingress to the service mesh instead.
      port "mongo" {
        static = 27017
        to = 27017
      }
    }

    service {
        name = "mongodb"
        port = "27017"

        connect{
        sidecar_service {}
      }
    } 

    volume "mongodb" {
      type      = "host"
      read_only = false
      source    = "mongodb"
    }

    task "mongotask" {
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
        // port_map {
        //   mongo = 27017
        // }
      }

      // resources {
      //   network {
      //     port "mongo" {
      //       static = 27017
      //     }
      //   }
      // }

           

    }
  }
  group "webblogfrontendgroup" {
    count = 2
    network {
      mode = "bridge"
      // port "http" {
      //   static = 8002
      //   to = 8001
      // }
    }

    service {
      name = "pythonfrontend"
      port = "8001"
      tags = [
          "traefik.tags=service",
          "traefik.frontend.rule=PathPrefixStrip:/",
        ]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mongodb"
              // local_bind_port is the port that the mongoDB upstream proxy is listening on so my python app needs to talk to mongo on this port
              local_bind_port = 8004
            }
          }
        }
      }
    }

    task "frontendtask" {
      driver = "docker"  
      
      env {
        DB_SERVER = "${NOMAD_UPSTREAM_IP_mongodb}"
        DB_PORT = "${NOMAD_UPSTREAM_PORT_mongodb}"
      }

      config {
        image = "samgabrail/webblog-nomad-demo:latest"
        // port_map {
        //   http = 80
        // }
      }

      vault {
        policies = ["webblog"]
      }
    }
  }
}