pipeline {
  agent any
  stages{
    stage('Build app image and push to nexus') {
      agent {
        docker {
          alwaysPull true
          args '-u 0:0'
          image 'nexus:8123/buildserver:latest'
        }
      }
      steps {
        cleanWs()
        sh 'git clone https://github.com/artem-pvl/devops_hw_11.git /conf'
        git 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git'
        withMaven {
          sh 'mvn package'
        }
        script {
          docker.withRegistry('http://nexus:8123', '6b2d0b83-9cca-4d23-b69b-bcf247bc8379') {
            sh 'cp ./target/hello-1.0.war /conf/prod'
            sh 'docker build --tag prodserver /conf/prod'
            sh 'docker tag prodserver nexus:8123/prodserver:latest'
            docker.image('prodserver').push('latest')
            sh 'docker image prune -a -f'
          }
        }
      }   
    }
    stage('Run prod docker container on node-1') {
      steps {
        sh 'rsync /conf/prod/docker-compose.yml root@node-1:./'
        sh 'ssh root@node-1 docker pull nexus:8123/prodserver:latest'
        sh 'ssh root@node-1 docker-compose up -d'
        sh 'ssh root@node-1 docker image prune -a -f'
      }
    }
  }
  post{
      success{
        cleanWs()
        chuckNorris()
      }
      failure{
        cleanWs()
        echo "||| *** ||| pipeline execution failed ||| *** |||"
      }
  }
}
