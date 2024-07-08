pipeline {
  parameters {
    string(name: 'VERSION', defaultValue: 'latest', description: 'Version number for the Docker image')
    string(name: 'PROJECT_NAME', defaultValue: 'demo_first_project', description: 'Name of the project')
    string(name: 'INDEX_URL', defaultValue: 'http://10.10.1.59:3141/kapil.bodas/test', description: 'Index URL for pip')
    string(name: 'authorName', defaultValue: '', description: 'Name of the author')
    string(name: 'readMe', defaultValue: '', description: 'Read Me content')
  }
  environment {
    registry = 'kapil321/another_office_repo' // Updated repository name
    registryCredentials = 'kapil-dockerhub-cred'
    dockerImage = ''
    img = ''
  }
  agent any
  stages {
    stage('Build Image') {
      steps {
        script {
          img = "${registry}:${VERSION}"
          dockerImage = docker.build(img, "--build-arg VERSION=${VERSION} --build-arg PROJECT_NAME=${PROJECT_NAME} --build-arg INDEX_URL=${INDEX_URL} .")
        }
      }
    }
    stage("Run the Image") {
      steps {
        script {
          // Stop and remove the existing container if it exists
          bat '''
            docker stop %JOB_NAME% || exit 0
            docker rm %JOB_NAME% || exit 0
          '''
          // Run the new container
          bat "docker run -d --name %JOB_NAME% -p 8000:8000 ${img}"
        }
      }
    }
    stage("Publish it to docker") {
      steps {
        script {
          // Login to Docker Hub
          withCredentials([usernamePassword(credentialsId: 'dockerhub_jenkins_id', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
            bat "echo %DOCKERHUB_PASSWORD% | docker login -u %DOCKERHUB_USERNAME% --password-stdin"
          }
          // Tag the Docker image with the version number
          bat "docker tag ${img} ${registry}:${VERSION}"
          // Push the Docker image to the registry
          bat "docker push ${registry}:${VERSION}"
        }
      }
    }
  }
}
