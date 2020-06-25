resource "google_container_cluster" "gke-cluster" {
  name               = "tf-cluster"
  network            = "default"
  location           = "europe-west1-b"
  initial_node_count = 1
}
