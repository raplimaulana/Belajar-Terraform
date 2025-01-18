# variable "host_os" {           #diisi ketika menjalankan terraform plan
#     type = string
# }

variable "host_os" {            #cara1
    type    = string
    default = "windows"
}

host_os = "linux"               #cara2

#override variable
# terraform console -var="host_os=unix"
# terraform console -var-file="variables.tf"