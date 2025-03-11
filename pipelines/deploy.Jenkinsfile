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
        stage('update YAML manifest') {
            steps {
                /*

                Now your turn! implement the pipeline steps ...

                - `cd` into the directory corresponding to the SERVICE_NAME variable.
                - Change the YAML manifests according to the new $IMAGE_FULL_NAME_PARAM parameter.
                  You can do so using `yq` or `sed` command, by a simple Python script, or any other method.
                - Commit the changes
                   * Setting global Git user.name and user.email in 'Manage Jenkins > System' is recommended.
                   * Setting Shell executable to `/bin/bash` in 'Manage Jenkins > System' is recommended.
                */
            }
        }
        stage('Git push') {
            steps {
               // Change `credentialsId` according to the Id you've configured your GitHub token
               withCredentials([
                usernamePassword(credentialsId: 'github', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')
               ]) {

                 sh 'git push https://$GITHUB_TOKEN@github.com/alonitac/NetflixInfra2.git main'

               }
            }
        }
        post {
            cleanup {
                cleanWs()
            }
        }
    }
}