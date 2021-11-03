pipeline {
  tools {
    terraform 'Terraform'
    git 'Default'
  }

  agent any
  stages {
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
        sh 'terraform output -json > servers_ip.json'
      }
    }
    stage('Provisioning infrastructure with Ansible') {
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
    stage('Build webserver image') {
      environment {
          DOCKERHUB_CREDS = credentials('dockerhub_token')
          // BUILD_SERVER_NAME = 'buildserver'
          // BUILD_SERVER_VERSION = '1.0'
      }
      steps {
        script {
          ipadr = readJSON file: 'servers_ip.json'
          echo "${ipadr.buildserver_ip.value}"
        }
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git /app"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mvn -f /app package"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mkdir -m 666 /webserver"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo cp /app/target/hello-1.0.war /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /app"
        sh "scp Dockerfile ubuntu@${ipadr.buildserver_ip.value}:/home/ubuntu"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mv /home/ubuntu/Dockerfile /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker build --tag webserver /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker tag webserver ${env.DOCKERHUB_CREDS_USR}/webserver:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker login -p ${env.DOCKERHUB_CREDS_PWD} -u ${env.DOCKERHUB_CREDS_USR}"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker push ${env.DOCKERHUB_CREDS_USR}/webserver:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker image prune -a -f"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /webserver"
        // withDockerServer([uri: "tcp://${ipadr.buildserver_ip.value}:2375", credentialsId: '']) {
        //   withDockerContainer(args: '-v /var/run/docker.sock:/var/run/docker.sock', image: 'artempvl/buildserver:1.0') {
        //     checkout scm
        //     // git 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git'
        //     sh 'git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git /web'
        //     // sh 'mvn -f /web package'
        //     // sh 'cp ./target/hello-1.0.war ./webserver/'
        //     // sh 'docker build --tag websrver ./webserver/'
        //     // sh 'docker tag webserver webserver:latest'
        //   }
        // }

          // docker.withServer("tcp://${ipadr.buildserver_ip.value}:2375", '') {
          //   docker.image('artempvl/buildserver:1.0').inside {
              // git 'https://github.com/boxfuse/boxfuse-sample-java-war-hello.git'

              // sh 'mvn package'

              // docker.withRegistry('', 'dockerhub_token') {
                // sh 'cp ./target/hello-1.0.war ./webserver'
                // sh 'docker build --tag websrver ./webserver'
                // sh 'docker tag webserver webserver:latest'
                // def newWeb = docker.build "artempvl/webserver:latest"
                // newWeb.push()
                // docker.image('webserver').push('latest')
                // docker.image('webserver').push('latest')
                // sh 'docker image prune -a -f'
              // }
            // }
          // }
        // }
      }
    }
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
