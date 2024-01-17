
variable "instance_type" {
  description = "The EC2 instance type for the Autoscaling Group"
  default     = "t3.micro" // Or your preferred instance type
}

variable "min_size" {
  description = "The minimum size of the Autoscaling Group"
  default     = 2
}

variable "max_size" {
  description = "The maximum size of the Autoscaling Group"
  default     = 5
}

variable "notification_email" {
  description = "Email address for receiving AWS SNS notifications"
  type        = string
  default     = "rohithkumar4490@gmail.com"
}
