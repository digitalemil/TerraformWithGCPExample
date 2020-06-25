terraform {
  backend "gcs" {
    bucket = "esiemes-default-tfstate"
    credentials = "./creds/serviceaccount.json"
  }
}
