provider "kubernetes" {
  config_path     = "~/.kube/config"
  config_context  = "docker-desktop"
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "parcial-virtu-app"
    labels = {
      App = "ParcialVirtuApp"
    }
  }

  spec {
    selector {
      match_labels = {
        App = "ParcialVirtuApp"
      }
    }
    template {
      metadata {
        labels = {
          App = "ParcialVirtuApp"
        }
      }
      spec {
        container {
          image = "j01gonza/parcial-virtu-app:latest"
          name  = "parcial-virtu-app"

          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "db" {
  metadata {
    name = "parcial-virtu-db"
    labels = {
      App = "ParcialVirtuDB"
    }
  }

  spec {
    selector {
      match_labels = {
        App = "ParcialVirtuDB"
      }
    }
    template {
      metadata {
        labels = {
          App = "ParcialVirtuDB"
        }
      }
      spec {
        container {
          image = "mongo:jammy"
          name  = "parcial-virtu-db"

          port {
            container_port = 27017
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name = "parcial-virtu-web"
    labels = {
      App = "ParcialVirtuWeb"
    }
  }

  spec {
    selector {
      match_labels = {
        App = "ParcialVirtuWeb"
      }
    }
    template {
      metadata {
        labels = {
          App = "ParcialVirtuWeb"
        }
      }
      spec {
        container {
          image = "httpd:latest"
          name  = "parcial-virtu-web"
          
          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "parcial-virtu-app"
  }
  spec {
    selector = {
      App = kubernetes_deployment.app.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 5000
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "db" {
  metadata {
    name = "parcial-virtu-db"
  }
  spec {
    selector = {
      App = kubernetes_deployment.db.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30202
      port        = 27017
      target_port = 27017
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "parcial-virtu-web"
  }
  spec {
    selector = {
      App = kubernetes_deployment.web.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30203
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}