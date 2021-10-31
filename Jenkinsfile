pipeline {
  tools {
    terraform 'Terraform'
    git 'Default'
  }

  agent any
  stages {
    environment {
        BUILDSRVER_IP = ''
        WEBSERVER_IP = ''
    }
    // stage('Get code of infrastucture') {
    //   git 'https://github.com/artem-pvl/devops_sertwork.git'
    // }
    stage('Create infrastructure with Terraform') {
      steps {
        withCredentials([file(credentialsId: 'aws_credentials', variable: 'aws_cred')]) {
          writeFile file: 'credentials', text: readFile(aws_cred)
        }
        sh 'terraform init'
        sh 'terraform plan'
        sh 'terraform apply -auto-approve'
      }
    }
    stage('Provisioning infrastructure with Ansible') {
      environment {
          DOCKERHUB_CREDS = credentials('dockerhub_token')
          BUILD_SERVER_NAME = 'buildserver'
          BUILD_SERVER_VERSION = '1.0'
      }
      steps {
        ansiblePlaybook(become: true,
                        becomeUser: 'ubuntu',
                        disableHostKeyChecking: true,
                        installation: 'Ansible',
                        inventory: 'hosts',
                        playbook: 'conveer.yml',
                        extras: '-vv'
        )
      }
    }
  //   stage('Build app image and push to nexus') {
  //     agent {
  //       docker {
  //         alwaysPull true
  //         args '-u 0:0'
  //         image 'nexus:8123/buildserver:latest'
  //       }
  //     }
  //     steps {
  //       cleanWs()
  //       sh 'git clone https://github.com/artem-pvl/devops_hw_11.git /conf'
  //       git 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git'
  //       withMaven {
  //         sh 'mvn package'
  //       }
  //       script {
  //         docker.withRegistry('http://nexus:8123', '6b2d0b83-9cca-4d23-b69b-bcf247bc8379') {
  //           sh 'cp ./target/hello-1.0.war /conf/prod'
  //           sh 'docker build --tag prodserver /conf/prod'
  //           sh 'docker tag prodserver nexus:8123/prodserver:latest'
  //           docker.image('prodserver').push('latest')
  //           sh 'docker image prune -a -f'
  //         }
  //       }
  //     }
  //   }
  //   stage('Run prod docker container on node-1') {
  //     steps {
  //       sh 'rsync /conf/prod/docker-compose.yml root@node-1:./'
  //       sh 'ssh root@node-1 docker pull nexus:8123/prodserver:latest'
  //       sh 'ssh root@node-1 docker-compose up -d'
  //       sh 'ssh root@node-1 docker image prune -a -f'
  //     }
  //   }
  }
  post {
      success {
        // cleanWs()
        chuckNorris()
      }
      failure {
        // cleanWs()
        echo '||| *** ||| pipeline execution failed ||| *** |||'
      }
  }
  agent {
    node {
      docker.withServer('tcp://swarm.example.com:2376', 'swarm-certs') {
          docker.image("${env.DOCKERHUB_CREDS_USR}/${env.BUILD_SERVER_NAME}:${env.BUILD_SERVER_VERSION}").withRun('') {
              /* do things */
            withMaven {
              sh 'mvn package'
            }
          }
      }
    }
  }
    // stage('Build webserver image and push to docker') {
    //   docker.withDockerServer([uri: "tcp://${env.BUILDSERVER_IP}:2376"]) {
    //     agent {
    //       docker {
    //         alwaysPull true
    //         args '-u 0:0'
    //         image "${env.DOCKERHUB_CREDS_USR}/${env.BUILD_SERVER_NAME}:${env.BUILD_SERVER_VERSION}"
    //       }
    //     }
    //     steps {
    //       sh 'git clone https://github.com/artem-pvl/devops_hw_11.git /conf'
    //       git 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git'
    //       withMaven {
    //         sh 'mvn package'
    //       }
          // script {
          //   docker.withRegistry('http://nexus:8123', '6b2d0b83-9cca-4d23-b69b-bcf247bc8379') {
          //     sh 'cp ./target/hello-1.0.war /conf/prod'
          //     sh 'docker build --tag prodserver /conf/prod'
          //     sh 'docker tag prodserver nexus:8123/prodserver:latest'
          //     docker.image('prodserver').push('latest')
          //     sh 'docker image prune -a -f'
          //   }
          // }
        // }
      // }
    // }
}
