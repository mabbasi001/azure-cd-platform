variable "subscription_id" {
  type = string
}

variable "github_owner" {
  type    = string
  default = "mabbasi001"
}

variable "github_repo" {
  type    = string
  default = "realworld-cd"
}

variable "application_display_name" {
  type    = string
  default = "github-actions-realworld-cd"
}

variable "federated_subjects" {
  description = "GitHub OIDC subjects granted access, keyed by a short name."
  type        = map(string)
  default = {
    main         = "repo:mabbasi001/realworld-cd:ref:refs/heads/main"
    develop      = "repo:mabbasi001/realworld-cd:ref:refs/heads/develop"
    pull_request = "repo:mabbasi001/realworld-cd:pull_request"
  }
}
