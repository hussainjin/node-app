pipeline {
    agent any
    //agent {label 'slave1'}
    environment{
        DOCKER_TAG = getDockerTag()
    }
    stages{
        stage('git clone')
        {
        steps{
            sh'rm -rf node-app'
            sh' git clone https://github.com/anilkumarpuli/node-app.git'
        }
        }
        stage('build'){
            steps{
                sh'mvn clean install'
            }
         }
           stage('Sonarqube') {
           environment {
           def scannerHome = tool 'sonar';
              }
            steps {
            withSonarQubeEnv('sonar'){
            sh "${scannerHome}/bin/sonar-scanner"
           }
         }
        }
        stage('Artifact upload') {
      steps {
//        nexusPublisher nexusInstanceId: 'nexusid', nexusRepositoryId: 'nexus-repo', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: '/var/lib/jenkins/workspace/pline-sonar-docker-k8s/target/vprofile-v1.war']], mavenCoordinate: [artifactId: 'vprofile', groupId: 'com.wakaleo.gameoflife', packaging: 'war', version: '$BUILD_NUMBER']]]      
            nexusArtifactUploader artifacts: [[artifactId: 'vprofile', classifier: '', file: '/var/lib/jenkins/workspace/pline-sonar-nexus-docker-k8s/target/vprofile-v1.war', type: 'war']], credentialsId: 'nexus-id', groupId: 'com.visualpathit', nexusUrl: '3.137.184.140:8081/repository/myrepo1/', nexusVersion: 'nexus3', protocol: 'http', repository: 'myrepo1', version: 'v1'
      }
     }
        //stage('deploy throuh ansible')
          //    {
         //steps{
           //      sshPublisher(publishers: [sshPublisherDesc(configName: 'ansible_server', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'ansible-playbook copywar.yml', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '/home/ansible', remoteDirectorySDF: false, removePrefix: '/home/ansible/workspace/workspace/pipeline/target', sourceFiles: '/home/ansible/workspace/workspace/pipeline/target/vprofile-v1.war')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)]) 
        // }
         // }
            //stage('deploy to tomcat')
         //{
        //steps
          //  {
      //deploy adapters: [tomcat9(credentialsId: 'tomcat', path: '', url: 'http://172.31.44.163:8080')], contextPath: 'anil', war: '**/*.war'        
       //}
        //}
        stage('Build Docker Image'){
            steps{
                sh 'docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi'
                sh "docker build . -t anilkumblepuli/java2:${DOCKER_TAG}"
            }
        }
        stage('DockerHub Push'){
            steps{
                   withCredentials([string(credentialsId: 'dockerpass2', variable: 'dockerpass2')])
                {                                   
                    sh  "docker login -u anilkumblepuli -p ${dockerpass2}"
                    sh  "docker push anilkumblepuli/java2:${DOCKER_TAG}"
                }
            }
        }
        stage('Deploy to k8s'){
            steps{
                sh "chmod +x changeTag.sh"
                sh "./changeTag.sh ${DOCKER_TAG}"
                sshagent(['k8pass']) {
                    sh "scp -o StrictHostKeyChecking=no services.yml node-app-pod.yml ubuntu@18.119.0.241:/home/ubuntu/"
                    script{
                        try{
                            
                            sh "ssh ubuntu@18.119.0.241 kubectl apply -f ."
                        }catch(error){
                            sh "ssh ubuntu@18.119.0.241 kubectl create -f ."
                            
                        }
                    }
                }
            }
        }
    }
}
def getDockerTag(){
    def tag  = sh script: 'git rev-parse HEAD', returnStdout: true
    return tag
}
