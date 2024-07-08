pipeline {
  parameters {
    string(name: 'VERSION', defaultValue: 'latest', description: 'Version number for the Docker image')
    string(name: 'PROJECT_NAME', defaultValue: 'demo_first_project', description: 'Name of the project')
    string(name: 'INDEX_URL', defaultValue: 'http://10.10.1.59:3141/kapil.bodas/test', description: 'Index URL for pip')
    string(name: 'authorName', defaultValue: '', description: 'Name of the author')
    string(name: 'readMe', defaultValue: '', description: 'Read Me content')
  }
  environment {
    registry = 'kapil321/internship_project' // Updated repository name
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
          sh """
            docker stop ${JOB_NAME} || true
            docker rm ${JOB_NAME} || true
          """
          // Run the new container
          sh "docker run -d --name ${JOB_NAME} -p 8000:8000 ${img}"
        }
      }
    }

    stage("Publish it to docker") {
      steps {
        script {
          // Login to Docker Hub
          withCredentials([usernamePassword(credentialsId: 'dockerhub_jenkins_id', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
            sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
          }

          // Tag the Docker image with the version number
          sh "docker tag ${img} ${registry}:${VERSION}"

          // Push the Docker image to the registry
          sh "docker push ${registry}:${VERSION}"
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
              <p>Build Number: ${BUILD_NUMBER}</p>
              <p>Version: ${params.VERSION}</p>
              <p>Author: ${params.authorName}</p>
              <p>Project Name: ${params.PROJECT_NAME}</p>
              <p>Read Me:</p>
              <pre>${params.readMe}</pre>
              <p>Check the <a href="${BUILD_URL}">Console Output</a>.</p>
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
          errorMessage = sh(script: 'docker run --rm ${img} cat /error.log', returnStdout: true).trim()
        } catch (Exception e) {
          errorMessage = "Error log not found or another error occurred"
        }
        emailext(
          subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
          body: """
            <html>
              <body>
                <p>Build Status: FAILURE</p>
                <p>Build Number: ${BUILD_NUMBER}</p>
                <p>Version: ${params.VERSION}</p>
                <p>Author: ${params.authorName}</p>
                <p>Project Name: ${params.PROJECT_NAME}</p>
                <p>Read Me:</p>
                <pre>${params.readMe}</pre>
                <p>Error Log:</p>
                <pre><span style="color:red;">${errorMessage}</span></pre>
                <p><span style="color:red;">Check the console log of the build in Jenkins Server. Please click the Console Output below.</span></p>
                <p>Check the <a href="${BUILD_URL}">Console Output</a>.</p>
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
