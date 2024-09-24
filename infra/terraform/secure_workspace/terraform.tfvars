deployment_name               = "#{DEPLOYMENT_NAME}#"
environment                   = "#{ENVIRONMENT}#"
location                      = "#{LOCATION}#"
vnet_address_space            = ["10.0.0.0/16"]
training_subnet_address_space = ["10.0.1.0/24"]
ml_subnet_address_space       = ["10.0.0.0/24"]
aml_image_build_compute = {
  name        = "image-builder",
  vm_priority = "LowPriority",
  vm_size     = "Standard_DS2_v2"
}