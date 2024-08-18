pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'testscript-assignment'
        UNIQUE_KEY = '01'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: ' https://github.com/stan4903/assignment.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Run the Docker container with the provided unique key
                    sh "docker run --rm ${DOCKER_IMAGE} ${UNIQUE_KEY}"
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker resources if needed
            sh "docker rmi ${DOCKER_IMAGE}"
        }
        success {
            echo 'The script ran successfully!'
        }
        failure {
            echo 'The script failed. Check the logs for more details.'
        }
    }
}
