output "instance_public_ip" {
  description = "EC2PublicIP"
  value       = aws_instance.react_app.public_ip
}
