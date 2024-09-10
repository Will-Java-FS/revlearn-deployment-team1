pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS = 'aws-credentials-id' // Replace with the ID of your AWS credentials in Jenkins
        GIT_CREDENTIALS = 'github-api-token' // Replace with the ID of your GitLab credentials in Jenkins
        GIT_URL = 'https://github.com/Will-Java-FS/revlearn-deployment-team1'
        KAFKA_TAG = 'kafka-ec2'
        JENKINS_TAG = 'jenkins-ec2'
        RDS_IDENTIFIER = 'revlearn-db'
        FRONTEND_BUCKET_NAME = 'frontend.revaturelearn.com'
        BEANSTALK_ENV_NAME = 'revlearn-springboot-env'
    }

    tools {
        terraform 'Terraform'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout main repository
                    checkout([$class: 'GitSCM',
                            branches: [[name: 'main']],
                            userRemoteConfigs: [[url: "${GIT_URL}", credentialsId: "${GIT_CREDENTIALS}"]]])
                }
            }
        }

        stage('Run TFLint') {
            steps {
                script {
                    dir('terraform') { // Change into 'terraform' directory
                        def dirs = ['.', 'network', 'kafka', 'rds', 'beanstalk', 's3-frontend', 'sonarqube', 's3-backend', 'jenkins']
                        for (dirName in dirs) {
                            dir(dirName) {
                                echo "TFLint: ${dirName == '.' ? 'Root' : dirName.capitalize()}"
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh 'tflint --init'
                                    sh 'tflint'
                                    echo "TFLint: ${dirName == '.' ? 'Root' : dirName.capitalize()} - No Issues found :)"
                                }
                            }
                        }
                    }
                }
            }
        }


        stage('Terraform Apply') {
            steps {
                script {
                    dir('terraform') {
                        def dirs = [ 'rds','kafka', 'beanstalk', 's3-frontend'] // Add the directories you want to apply Terraform in
                        for (dirName in dirs) {
                            dir(dirName) { // Change to the specific subdirectory
                                echo "Terraform Apply in ${dirName.capitalize()}"
                                withAWS(region: "${AWS_REGION}", credentials: "${AWS_CREDENTIALS}") {
                                    // Initialize and apply Terraform configurations
                                    sh 'terraform init -input=false'
                                    sh 'terraform apply -auto-approve'
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Find Resource URLs') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: "${AWS_CREDENTIALS}") {
                        // Find Kafka EC2 instance
                        def kafkaInstanceId = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${env.KAFKA_TAG}\" --query \"Reservations[*].Instances[*].InstanceId\" --output text", returnStdout: true).trim()
                        if (kafkaInstanceId) {
                            def kafkaPublicDns = sh(script: "aws ec2 describe-instances --instance-ids ${kafkaInstanceId} --query \"Reservations[*].Instances[*].PublicDnsName\" --output text", returnStdout: true).trim()
                            echo "Kafka EC2 Public DNS: ${kafkaPublicDns}"
                            env.KAFKA_PUBLIC_DNS = kafkaPublicDns
                        } else {
                            echo 'No Kafka EC2 instance found'
                        }

                        // Find Jenkins EC2 instance
                        def jenkinsInstanceId = sh(script: "aws ec2 describe-instances --filters \"Name=tag:Name,Values=${env.JENKINS_TAG}\" --query \"Reservations[*].Instances[*].InstanceId\" --output text", returnStdout: true).trim()
                        if (jenkinsInstanceId) {
                            def jenkinsPublicDns = sh(script: "aws ec2 describe-instances --instance-ids ${jenkinsInstanceId} --query \"Reservations[*].Instances[*].PublicDnsName\" --output text", returnStdout: true).trim()
                            echo "Jenkins EC2 Public DNS: ${jenkinsPublicDns}"
                            env.JENKINS_PUBLIC_DNS = "http://" + jenkinsPublicDns
                        } else {
                            echo 'No Jenkins EC2 instance found'
                        }

                        // Find RDS instance using identifier
                        def rdsEndpoint = sh(script: "aws rds describe-db-instances --db-instance-identifier ${env.RDS_IDENTIFIER} --query \"DBInstances[0].Endpoint.Address\" --output text", returnStdout: true).trim()
                        if (rdsEndpoint) {
                            echo "RDS Endpoint: ${rdsEndpoint}"
                            env.RDS_ENDPOINT = rdsEndpoint
                        } else {
                            echo 'No RDS instance found'
                        }


                        // Find Frontend S3 Bucket
                        echo "Frontend S3 Bucket Name: ${env.FRONTEND_BUCKET_NAME}"
                        // Construct the S3 bucket URL
                        def s3BucketUrl = "http://${env.FRONTEND_BUCKET_NAME}.s3.amazonaws.com/"
                        echo "Frontend S3 Bucket URL: ${s3BucketUrl}"
                        env.S3_BUCKET_URL = s3BucketUrl

                        // Find Beanstalk Environment URL
                        def beanstalkUrl = sh(script: "aws elasticbeanstalk describe-environments --environment-names ${env.BEANSTALK_ENV_NAME} --query 'Environments[0].CNAME' --output text", returnStdout: true).trim()
                        if (beanstalkUrl) {
                            echo "Beanstalk Environment URL: ${beanstalkUrl}"
                            env.BACKEND_URL = "http://" + beanstalkUrl
                        } else {
                            echo 'No Beanstalk environment found'
                        }
                    }
                }
            }
        }

        stage('Save URLS to Secrets Manager') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: "${AWS_CREDENTIALS}") {
                        def secretName = 'revlearn/urls'
                        def secretsJson = [
                            kafka_url: env.KAFKA_PUBLIC_DNS ?: '',
                            jenkins_url: env.JENKINS_PUBLIC_DNS ?: '',
                            frontend_url: env.S3_BUCKET_URL ?: '',
                            rds_url: env.RDS_ENDPOINT ?: '',
                            backend_url: env.BACKEND_URL ?: ''
                        ]
                        def secretsString = groovy.json.JsonOutput.toJson(secretsJson)

                        // Update the secret in AWS Secrets Manager
                        sh """
                        aws secretsmanager update-secret --secret-id ${secretName} --secret-string '${secretsString}'
                        """
                    }
                }
            }
        }

        stage('Run Ansible') {
            steps {
                script {
                    dir('ansible') {
                        echo 'Running Ansible configuration for Kafka'
                        sh 'sh run_ansible.sh kafka'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
