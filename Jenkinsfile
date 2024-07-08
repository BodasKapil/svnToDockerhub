pipeline {
  agent any

  environment {
    registry = 'kapil321/another_office_repo'
  }

  stages {
    stage('Build Image') {
      steps {
        script {
          def img = "${registry}:${VERSION}"
          dockerImage = docker.build(img, "--build-arg VERSION=${VERSION} --build-arg PROJECT_NAME=${PROJECT_NAME} --build-arg INDEX_URL=${INDEX_URL} .")
        }
      }
    }

    stage("Run the Image") {
      steps {
        script {
          def imageName = "${registry}:${VERSION}"
          // Stop the container if it exists
          bat "docker stop ${JOB_NAME} || true"
          // Remove the container if it exists
          bat "docker rm ${JOB_NAME} || true"
          // Run the new container
          bat "docker run -d --name ${JOB_NAME} -p 8000:8000 ${imageName}"
        }
      }
    }

    stage("Publish to Registry") {
      steps {
        script {
          // Login to Docker Hub
          withCredentials([usernamePassword(credentialsId: 'dockerhub_password', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
            bat "docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}"
            // Tag the Docker image with the version number
            bat "docker tag ${img} ${registry}:${VERSION}"
            // Push the Docker image to the registry
            bat "docker push ${registry}:${VERSION}"
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
          // Attempt to fetch error logs if available
          errorMessage = bat(script: "docker run --rm ${img} cat /error.log", returnStdout: true).trim()
        } catch (Exception e) {
          errorMessage = "Error log not found or another error occurred"
        }
        // Send email notification on failure
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
