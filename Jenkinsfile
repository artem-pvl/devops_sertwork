pipeline {
  tools {
    terraform 'Terraform'
    git 'Default'
  }
  environment {
      DOCKERHUB_CREDS = credentials('dockerhub_token')
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
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker build -t ws /webserver/"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker tag ws ${env.DOCKERHUB_CREDS_USR}/ws:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker logout"
        sh "echo '$DOCKERHUB_CREDS_PSW' | ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker login --username $DOCKERHUB_CREDS_USR --password-stdin"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker push ${env.DOCKERHUB_CREDS_USR}/ws:latest"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo docker image prune -a -f"
        sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /webserver"
      }
      post {
        failure {
          sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /app"
          sh "ssh ubuntu@${ipadr.buildserver_ip.value} sudo rm -rf /webserver"
        }
      }
    }
    stage('Run webserver') {
      steps {
        sh "rsync docker-compose.yml ubuntu@${ipadr.webserver_ip.value}:~/"
        sh "ssh ubuntu@${ipadr.webserver_ip.value} sudo docker pull ${env.DOCKERHUB_CREDS_USR}/ws:latest"
        sh "ssh ubuntu@${ipadr.webserver_ip.value} sudo docker-compose up -d"
      }
    }
  }
  post {
      success {
        chuckNorris()
      }
      failure {
        echo '||| *** ||| pipeline execution failed ||| *** |||'
      }
  }
}
