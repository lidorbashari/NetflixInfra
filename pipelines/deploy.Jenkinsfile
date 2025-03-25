pipeline {
    agent any

    parameters {
        string(name: 'SERVICE_NAME', defaultValue: '', description: '')
        string(name: 'IMAGE_FULL_NAME_PARAM', defaultValue: '', description: '')
    }

    stages {
        stage('Git setup') {
            steps {
                /*
                Jenkins checks out a specific commit, rather than HEAD of the repo.
                This puts the repo in a "detached" state, which doesn't allow committing and pushing.
                Thus you have to checkout out the branch explicitly, as below.
                */

                sh 'git checkout -b main || git checkout main'
            }
        }
        stage('Update YAML manifest') {
            steps {
                script {
                    def yamlFile = "k8s/prod/${params.SERVICE_NAME}/deployment.yaml"
                    def image = params.IMAGE_FULL_NAME_PARAM ?: 'lidorbashari/netflix-frontend:latest'

                    sh """
                        if [ -f "${yamlFile}" ]; then
                            sed -i 's|image: .*|image: ${image}|' ${yamlFile}
                        else
                            echo "ERROR: ${yamlFile} not found!"
                            exit 1
                        fi
                    """

                    sh """
                        git config --global user.email "jenkins@yourcompany.com"
                        git config --global user.name "Jenkins"
                        git add ${yamlFile}
                        git commit -m "Update ${params.SERVICE_NAME} image to ${params.IMAGE_FULL_NAME_PARAM}"
                    """
                }
            }
        }

        stage('Git push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
                    sh 'git push https://$GITHUB_TOKEN@github.com/lidorbashari/NetflixInfra.git main'
                }
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        }
    }
}