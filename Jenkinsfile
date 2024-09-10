pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS = 'aws-credentials-id' // Replace with the ID of your AWS credentials in Jenkins
        GIT_CREDENTIALS = 'github-api-token' // Replace with the ID of your GitLab credentials in Jenkins
        GIT_URL = 'https://github.com/Will-Java-FS/revlearn-deployment-team1'
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
                            branches: [[name: 'develop']],
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
    }

    post {
        always {
            cleanWs()
        }
    }
}
