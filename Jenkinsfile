pipeline {
    agent any
    environment {
        DOCKER_IMAGE_TAG = "luckydepot-${BUILD_NUMBER}"
        DOCKER_IMAGE = "luckydepot:${DOCKER_IMAGE_TAG}"
        REMOTE_HOST = "192.168.50.38"  // Ubuntu 서버 IP 주소
        REMOTE_USER = "jenkins"      // Ubuntu 서버 사용자명
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker Image with tag: ${DOCKER_IMAGE_TAG}"
                    docker build -t luckydepot:${DOCKER_IMAGE_TAG} -f Dockerfile .
                    echo "Tagging image as latest"
                    docker tag luckydepot:${DOCKER_IMAGE_TAG} luckydepot:latest
                '''
            }
        }
        // stage("Deploy") {
        //     steps {
        //         sh '''
        //             echo "Deploying Docker Image with tag: ${DOCKER_IMAGE_TAG}"
        //             DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} \
        //             docker-compose -f docker-compose.yml up -d --build
        //         '''
        //     }
        // }
        stage('Deploy') {
            steps {
                sh '''
                    echo "Deploying application with Docker Compose"
                    DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} \
                    docker-compose -f docker-compose.yml up -d --build
                '''
            }
        }
    }
}
