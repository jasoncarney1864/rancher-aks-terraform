variable "name" {
  type = string
}

variable "repository" {
  type = string
}

variable "chart" {
  type = string
}

variable "namespace" {
  type = string
}

variable "create_namespace" {
  type    = bool
  default = true
}

variable "sets" {
  type    = map(any)
  default = {}
}
