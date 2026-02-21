resource "aws_instance" "module-ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.skenario-1-sg.id]
  iam_instance_profile = var.iam_instance_profile

  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  user_data                   = data.template_file.skenario-1.rendered
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-Instance"
  }
  lifecycle {
    ignore_changes = [ iam_instance_profile ]
  }
}
data "template_file" "skenario-1" {
  template = file("${path.module}/user-data.sh")
}