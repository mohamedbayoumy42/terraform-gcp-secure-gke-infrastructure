variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = "sela-sandboxing-prj"
}

variable "region" {
  description = "Region for resources"
  default     = "me-central2"
}

variable "cluster_name" {
  default = "sela-cluster"
}