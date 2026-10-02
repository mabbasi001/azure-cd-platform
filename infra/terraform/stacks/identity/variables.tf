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

# GitHub issues OIDC tokens with "immutable" subjects for this repo (account and
# repo database IDs embedded), so the federated subjects use that prefix.
variable "oidc_subject_prefix" {
  type    = string
  default = "repo:mabbasi001@121091435/realworld-cd@1402088929"
}

variable "federated_subjects" {
  description = "GitHub OIDC subject suffixes granted access, keyed by a short name."
  type        = map(string)
  default = {
    main         = "ref:refs/heads/main"
    develop      = "ref:refs/heads/develop"
    pull_request = "pull_request"
  }
}
