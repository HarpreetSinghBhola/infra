pipeline {
  agent any
	environment {
		AWS_DEFAULT_REGION = "${params.AWS_REGION}"
		PROFILE = "${params.PROFILE}"
		ACTION = "${params.ACTION}"
		PROJECT_DIR = "infra/eks"
    }
	options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        timeout(time: 2, unit: 'HOURS')
        disableConcurrentBuilds()
    }
	parameters {

		choice (name: 'AWS_REGION',
				choices: ['eu-west-1'],
				description: 'Pick A regions defaults to eu-west-1')
		string (name: 'ENV_NAME',
			   defaultValue: 'dev',
			   description: 'Env or Customer name')
		choice (name: 'ACTION',
				choices: [ 'plan', 'apply', 'destroy'],
				description: 'Run terraform plan / apply / destroy')
		string (name: 'PROFILE',
			   defaultValue: 'dev-aws',
			   description: 'Optional. Target aws profile defaults to dev-aws')
    }
	stages {
		stage('Checkout'){
			steps {
				script {
						withCredentials(bindings: [usernamePassword(credentialsId: PROFILE, \
                            usernameVariable: 'aws_access_id',passwordVariable: 'aws_secret_key')])
							{
							try {
                                cleanUp()
				checkout scm
						
                                sh"""
				    pwd
				    ls -l
                                    /usr/local/bin/aws configure --profile ${PROFILE} set aws_access_key_id ${aws_access_id}
                                    /usr/local/bin/aws configure --profile ${PROFILE} set aws_secret_access_key ${aws_secret_key}
                                    /usr/local/bin/aws configure --profile ${PROFILE} set region ${AWS_REGION}
                                    export AWS_PROFILE=${PROFILE}
                                """
							} catch (ex) {
                                echo 'Err:  Build failed with Error in Checjout Stage: ' + ex.toString()
								currentBuild.result = "FAILED"
								sh 'exit 1'
							}
						}
					}
				}
			}
		
		stage('terraform plan') {
			when { anyOf
					{
						environment name: 'ACTION', value: 'plan';
						environment name: 'ACTION', value: 'apply'
					}
				}
			steps {
				dir("${PROJECT_DIR}") {
					script {
                            try {
                                tfCmd('plan', '-detailed-exitcode -out=tfplan')
                            } catch (ex) {
                                if (ex == 2 && "${ACTION}" == 'apply') {
                                    currentBuild.result = "FAILED"
                                } else if (ex == 2 && "${ACTION}" == 'plan') {
                                    echo "Update found in plan tfplan"
                                } else {
                                    echo "Try running terraform again in debug mode"
                                }
								sh 'exit 1'
                            }
                    }
                }
            }
        }
		stage('terraform apply') {
			when { anyOf
					{
						environment name: 'ACTION', value: 'apply'
					}
				}
			steps {
				dir("${PROJECT_DIR}") {
					script {
                            try {
                                tfCmd('apply', 'tfplan')
                            } catch (ex) {
                			currentBuild.result = "FAILED"
							sh "exit 1"
                            }
                    }
                }
            }
        }
		stage('terraform destroy') {    
			when { anyOf
					{
						environment name: 'ACTION', value: 'destroy';
					}
				}
			steps {
				script {
					def IS_APPROVED = input(
						message: "Destroy ${ENV_NAME} !?!",
						ok: "Yes",
						parameters: [
							string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
						]
					)
					if (IS_APPROVED != 'Yes') {
						currentBuild.result = "ABORTED"
						error "User cancelled"
					}
				}
				dir("${PROJECT_DIR}") {
					script {
                            try {
                                tfCmd('destroy', '-auto-approve')
                            } catch (ex) {
                                currentBuild.result = "FAILED"
								sh 'exit 1'
                            }
					}
				}
			}
		}
		stage('Configure EKS Cluster') {
			when { anyOf
					{
						environment name: 'ACTION', value: 'apply'
					}
				}
			steps {
				dir("${PROJECT_DIR}") {
					script {
                            try {
                                sh '''
								echo Deploying Metric server..
								kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
								'''
                            } catch (ex) {
                			currentBuild.result = "FAILED"
							sh "exit 1"
                            }
						}
					}
				}
			}	
		}
  post {
        always {
            node('') { 
                echo "Finalising"
                sh '''
                set +x
                /usr/local/bin/aws configure --profile ${PROFILE} set aws_access_key_id ''
                /usr/local/bin/aws configure --profile ${PROFILE} set aws_secret_access_key ''
                set -x
                '''
            }
        }
    }
}

def tfCmd(String command, String options = '') {
	ACCESS = "export AWS_PROFILE=${PROFILE}"
	sh ("cd $WORKSPACE/infra/eks && ${ACCESS} && terraform init -reconfigure")
	sh ("cd $WORKSPACE/infra/eks && terraform workspace select ${ENV_NAME} || terraform workspace new ${ENV_NAME}")
	sh ("echo ${command} ${options}") 
    sh ("cd $WORKSPACE/infra/eks && ${ACCESS} && terraform init && terraform ${command} ${options} && terraform show -no-color > show-${ENV_NAME}.txt")
}

def cleanUp() {
	echo "Cleaning up"
	sh """#!/bin/bash
		rm -rf *
		rm -rf .*
		ls -a
	"""
	echo "End of cleanup"
}



