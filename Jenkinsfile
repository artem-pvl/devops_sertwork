pipeline {
  tools {
    terraform 'Terraform'
    git 'Default'
  }

  agent any
  stages {
    stage('Create infrastructure with Terraform') {
      steps {
        withCredentials([file(credentialsId: 'aws_credentials', variable: 'aws_cred')]) {
          writeFile file: 'credentials', text: readFile(aws_cred)
        }
        sh 'terraform init'
        sh 'terraform plan -out=plan'
        sh 'terraform apply -auto-approve plan'
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
    stage('Build webserver image') {
      environment {
          DOCKERHUB_CREDS = credentials('dockerhub_token')
      }
      steps {
        script {
          ipadr = readJSON file: 'servers_ip.json'
          echo "${ipadr.buildserver_ip.value}"
          env.IP_BUILD = ipadr.buildserver_ip.value
        }
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git /app"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mvn -f /app package"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mkdir -m 666 /webserver"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo cp /app/target/hello-1.0.war /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /app"
        sh "scp Dockerfile ubuntu@${ipadr.buildserver_ip.value}:/home/ubuntu"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo mv /home/ubuntu/Dockerfile /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker build --tag webserver /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker tag webserver:latest ${env.DOCKERHUB_CREDS_USR}/webserver:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo echo '$DOCKERHUB_CREDS_PSW' | docker login --username $DOCKERHUB_CREDS_USR --password-stdin"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker push ${env.DOCKERHUB_CREDS_USR}/webserver:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker image prune -a -f"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /webserver"
      }
      failure {
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /app"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /webserver"
      }
    }
    stage('Run webserver') {
      steps {
        sh "rsync docker-compose.yml ubuntu@${ipadr.webserver_ip.value}:~/"
        sh "ssh ubuntu@${ipadr.webserver_ip.value} sudo docker pull ${env.DOCKERHUB_CREDS_USR}/webserver:latest"
        sh "ssh ubuntu@${ipadr.webserver_ip.value} sudo docker-compose up -d"
        // $
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
