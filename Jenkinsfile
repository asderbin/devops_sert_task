pipeline {
    agent any

    stages {
        stage('Terraform Apply') {
            steps {
                dir('/home/asderbin/') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Build and Deploy') {
            steps {
                script {
                    //Getting IP addresses using Terraform output
                    def buildNodeIP = sh(script: "terraform output -json build_node_ip | jq -r '.value'", returnStdout: true).trim()
                    def appNodeIP = sh(script: "terraform output -json app_node_ip | jq -r '.value'", returnStdout: true).trim()

                    // Setting environment variables to use in the next step
                    env.BUILD_NODE_IP = buildNodeIP
                    env.APP_NODE_IP = appNodeIP

                    // Go to the /home/keglia/ directory and execute Ansible playbook
                    dir('/home/asderbin/') {
                        sh "ansible-playbook -i \"${BUILD_NODE_IP},${APP_NODE_IP}\" build_deploy.yml"
                    }
                }
            }
        }
    }
}