pipeline {
    
    agent { label 'pearl' }

    options {
        // we push things to a registry that are tagged by branch
        // without this we may get race conditions
        disableConcurrentBuilds()

        timeout(time: 1, unit: 'HOURS')
    }

    // jenkins job multibranch configuration
    parameters {

        booleanParam(name: 'BUILD_AMI', defaultValue: false, description: 'Build a new AMI?')

        choice(name: 'WHICH_AMI', choices: ['AWSLINBUILD7', 'AWSWINBUILD'], description: 'Choose which AMIs you want to build')

        booleanParam(name: 'SEND_EMAIL', defaultValue: false, description: 'Do you want to send an email on completion?')

        string(name: 'EMAIL_ADDRESS', defaultValue: 'development@aria-networks.com', description: 'If you want to send an email where do you want to send it?')

    }

    stages {
        
        stage('Create Packer AMI') {
            when {
                 expression {params.BUILD_AMI==true}
            }

            steps {
              withCredentials([
                    usernamePassword(credentialsId: '2ceae515-c71e-4d66-a16a-57295d207e8f', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_KEY')
                  ]) {
                    sh """
                    sudo yum install jq ansible -y
                    ./build-vm -force ${params.WHICH_AMI} -only=amazon-ebs -var aws_access_key=${AWS_KEY} -var aws_secret_key=${AWS_SECRET}
                    export AMI_ID=\$(cat packer/manifest.json | jq -r '.builds[-1].artifact_id' |  cut -d':' -f2)
                    echo \$AMI_ID > AMI.txt
                    """
                }
            }

        }
        stage('AWS Deployment') {
            when {
                 expression {params.BUILD_INSTANCE==true}
            }    
            //environment { 
                    //AMI_ID = sh (returnStdout: true, script: "cat packer/manifest.json | jq -r '.builds[-1].artifact_id' |  cut -d':' -f2").trim()
                    //LIFESPAN=sh (returnStdout: true, script: "date --rfc-3339=seconds -d '${params.INSTANCE_LIFESPAN}' | sed 's/ /T/'").trim()

            //    }

            steps {
                  withCredentials([
                    usernamePassword(credentialsId: '05205e4d-d491-4544-849b-265946acbb43', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_KEY'),
                  ]) {
                sh """
                   env
                   cd packer/provisioners/ansible/files
                   wget https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war
                   cd ../../../../terraform
                   terraform init
                   export AWS_ACCESS_KEY_ID=${AWS_KEY}
                   export AWS_SECRET_ACCESS_KEY=${AWS_SECRET}
                   terraform import aws_vpc.aria_vpc vpc-0aca370fca2ffdb02
                   terraform plan -var 'AMI_ID=${params.WHICH_AMI}' -var 'LIFESPAN=${params.INSTANCE_LIFESPAN}' -var 'USERNAME=${params.USERNAME}' -out=instance.out .
                   terraform apply -auto-approve instance.out
                   export INSTANCE_IP=\$(terraform output ip)
                   echo \$INSTANCE_IP > IP.txt
                """
                 // -var ami_name=${params.DOCKER_TAG}
                }

            }

            post {   
                
                always {
                    archiveArtifacts artifacts: 'AMI.txt', fingerprint: true
                }
         
                 success {  
                    script {
                      if (params.SEND_EMAIL==true) {
                          mail bcc: '', body: "<b>ANN</b><br>Build: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Build URL: ${env.BUILD_URL} <br> Instance IP: Please follow the link above to get the instance IP ", cc: '', charset: 'UTF-8', from: 'cloud-admin@aria-networks.com', mimeType: 'text/html', replyTo: '', subject: "Project name -> ${env.JOB_NAME}", to: "${params.EMAIL_ADDRESS}";          
                      }
                  }      
               }  
            }    
        }
    }
}

