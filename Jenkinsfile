pipeline {
    agent { docker { image 'python:3.5.1' } }
    stages {
        stage('build') {
            steps {
                sh '/usr/bin/python3 --version'
            }
        }
    }
}
