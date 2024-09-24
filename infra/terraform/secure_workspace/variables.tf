variable "deployment_name" {
  type        = string
  description = "Name of the deployment"
  default     = "MSProEUEI"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
  default     = ""
}

variable "location" {
  type        = string
  description = "Location of the resources"
  default     = "eastus2"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space of the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "training_subnet_address_space" {
  type        = list(string)
  description = "Address space of the training subnet"
  default     = ["10.0.1.0/24"]
}

variable "ml_subnet_address_space" {
  type        = list(string)
  description = "Address space of the ML workspace subnet"
  default     = ["10.0.0.0/24"]
}

variable "aml_image_build_compute" {
  type = object({
    name        = string
    vm_priority = string,
    vm_size     = string
  })
  description = "Details for compute cluster for building image."
  default = {
    name        = "image-builder",
    vm_priority = "LowPriority",
    vm_size     = "Standard_DS2_v2"
  }
}