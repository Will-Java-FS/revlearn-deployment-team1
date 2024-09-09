resource "aws_elastic_beanstalk_application" "springboot_app" {
  name        = "revlearn-springboot-app"
  description = "Revlearn Spring Boot application running on Beanstalk"
}
