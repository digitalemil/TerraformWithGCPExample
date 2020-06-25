provider "google" {
  credentials = file("./creds/serviceaccount.json")
  project     = "esiemes-default"
  region      = "europe-west1"
}
