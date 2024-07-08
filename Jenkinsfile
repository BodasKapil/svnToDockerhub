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
    registryURL = 'docker.io' // Default registry URL for Docker Hub, adjust as per your Docker registry
  }
  agent any

  stages {
    stage('Build Image') {
      steps {
        script {
          def img = "${registry}:${VERSION}"
          def dockerImage = docker.build(img, "--build-arg VERSION=${VERSION} --build-arg PROJECT_NAME=${PROJECT_NAME} --build-arg INDEX_URL=${INDEX_URL} .")
        }
      }
    }

    stage("Run the Image") {
      steps {
        script {
          def imageName = "${registry}:${VERSION}"
          // Stop and remove the existing container if it exists
          bat "docker stop ${env.JOB_NAME} || exit 0"
          bat "docker rm ${env.JOB_NAME} || exit 0"
          // Run the new container
          bat "docker run -d --name ${env.JOB_NAME} -p 8000:8000 ${imageName}"
        }
      }
    }

    stage("Publish to Registry") {
      steps {
        script {
          // Login to Docker Hub with username and PAT (Personal Access Token)
          withCredentials([usernamePassword(credentialsId: 'dockerhub_password', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_TOKEN')]) {
            bat "echo ${DOCKERHUB_TOKEN} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
            
            // Push the Docker image to the specified registry
            bat "docker tag ${registry}:${VERSION} ${registryURL}/${registry}:${VERSION}"
            bat "docker push ${registryURL}/${registry}:${VERSION}"
          }
        }
      }
    }
  }

  post {
    success {
      emailext(
        subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
        body: """
          <html>
            <body>
              <p>Build Status: SUCCESS</p>
              <p>Build Number: ${env.BUILD_NUMBER}</p>
              <p>Version: ${params.VERSION}</p>
              <p>Author: ${params.authorName}</p>
              <p>Project Name: ${params.PROJECT_NAME}</p>
              <p>Read Me:</p>
              <pre>${params.readMe}</pre>
              <p>Check the <a href="${env.BUILD_URL}">Console Output</a>.</p>
            </body>
          </html>
        """,
        to: 'kapil.bodas.cerelabs@gmail.com',
        from: 'jenkins@example.com',
        replyTo: 'jenkins@example.com',
        mimeType: 'text/html'
      )
    }
    failure {
      script {
        def errorMessage = ""
        try {
          errorMessage = bat(script: "docker run --rm ${registry}:${VERSION} cat /error.log", returnStdout: true).trim()
        } catch (Exception e) {
          errorMessage = "Error log not found or another error occurred"
        }
        emailext(
          subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
          body: """
            <html>
              <body>
                <p>Build Status: FAILURE</p>
                <p>Build Number: ${env.BUILD_NUMBER}</p>
                <p>Version: ${params.VERSION}</p>
                <p>Author: ${params.authorName}</p>
                <p>Project Name: ${params.PROJECT_NAME}</p>
                <p>Read Me:</p>
                <pre>${params.readMe}</pre>
                <p>Error Log:</p>
                <pre><span style="color:red;">${errorMessage}</span></pre>
                <p><span style="color:red;">Check the console log of the build in Jenkins Server. Please click the Console Output below.</span></p>
                <p>Check the <a href="${env.BUILD_URL}">Console Output</a>.</p>
              </body>
            </html>
          """,
          to: 'kapil.bodas.cerelabs@gmail.com',
          from: 'jenkins@example.com',
          replyTo: 'jenkins@example.com',
          mimeType: 'text/html'
        )
      }
    }
  }
}
