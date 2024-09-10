resource "aws_elastic_beanstalk_environment" "springboot_env" {
  name                = "revlearn-springboot-env"
  application         = aws_elastic_beanstalk_application.springboot_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.7.5 running Corretto 17" # Adjust based on your JDK version

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"  # Adjust instance type as needed
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_ec2_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance" # LoadBalanced Or SingleInstance for smaller setups
  }

    setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = var.subnet_id
  }

  tags = {
    Name = "revlearn-springboot-env"
    Owner = "Trey-Crossley"
  }
}