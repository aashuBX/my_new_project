// General Notes for pipeline

// 1. You need to create the directory in each git resository 
// 2. Name of directory will be task-definitons/${ENV}
// 3. For example QA ENV --> it will be task-definitons/QA, for staging --> task-definitions/staging
// 4. You need to put task-definition.json for each env & each worker in that respective directory
// 5. This Jenkinsfile is created such like you only need to edit the each env stage parameters only, all other 
//    stages are generalised ( taking input from env variables ) 
// 6. And in each env stage, only some parameters need to be changes,not all

// 7. env.ECS_SERVICES, env.TASK_DEFINITION_FILE_NAMES, env.TASK_DEFINITION_FILE_PATH
// <-------------Above environment variables defined in each environment related stage are indexed with each other---------------> 
// So make sure to define these env variables corresponding to each other like below 
//  env.ECS_SERVICES[0]                        env.ECS_SERVICES[1]                     env.ECS_SERVICES[2]   
//  env.ECS_TASK_DEFINITION_FILE_NAMES[0]      env.ECS_TASK_DEFINITION_FILE_NAMES[1]   env.ECS_TASK_DEFINITION_FILE_NAMES[2]
//  env.TASK_DEFINITION_FILE_PATH[0]           env.TASK_DEFINITION_FILE_PATH[1]        env.TASK_DEFINITION_FILE_PATH[2]

@Library('sm-jenkins-shared-library@api') _
pipeline {
    agent {
        label "slave-1"
    }
    environment {
        IMAGE_REPO_NAME = 'api/conversive-button-management' // Name of ECR Repository ( change this as per your project )
        PROJECT_NAME = 'conversive-button-management'       // Name of your project
        ECS_CLUSTER_NAME = 'api-cluster-ecs' // Name of ECS cluster (Keep this same for api projects)
        AWS_MAX_ATTEMPTS = '10' // Maximum no of retries 
    }
    options {
        buildDiscarder(
            logRotator(
                numToKeepStr: '7',
                daysToKeepStr: '10',
            )
        )
    }

    stages {
        stage('User Input stage'){
            // when { tag 'v*' }
            when { 
                anyOf {
                    tag 'v*'
                    branch "prod-feature-branch"
                }
            }
            steps {
                script {
                    env.ENVIRONMENT = input(message: 'Please choose the deployment env',
                    parameters: [
                        choice(
                            choices: ['prod_aus', 'prod_eu', 'prod_us'],
                            description: '',
                            name: 'Environment'
                        )
                    ])
                }
            }
        }
        // This stage will be executed only if branch is qa 
        // In this stage we are defining the env variables for deployment in QA ENV
        stage('QA Env') {
            when { 
                anyOf {
                    branch "qa"
                    branch "qa-feature-branch"
                }
            }
            steps {
                script {
                    set_QA_Constant_Env() // please do not change this 

                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/qa/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:us-east-1:454947665516:targetgroup/sm-tg-conversive-button-management/bff0b4e78532a55a
                    '''
                }
            } 
        }
        // This stage will be executed if branch is integration
        stage('Integration Env') {
            when { 
                anyOf {
                    branch "integration"
                    branch "integration-feature-branch" 
                }
            }  
            steps {
                script {
                    set_Integration_Constant_Env() // please do not change this 
                     
                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/integration/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:us-east-1:134746102940:targetgroup/sm-tg-conversive-button-manag/1e445b49b02f768d
                    '''
                }
            }
        }
        // This stage will be executed if tag is rc-* ( we deploy in staging using tag rc-* )
        stage('Staging Env') {
            // when { tag 'rc-*' }
            when { 
                anyOf {
                    tag 'rc-*'
                    branch "staging-feature-branch"
                }
            }
            steps {
                script {
                    set_Staging_Constant_Env() // please do not change this 

                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/staging/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:us-east-1:346900201582:targetgroup/conversive-button-management/8d915d4699bf0ba6
                    '''
                }
            }
        }
        // This stage will be executed if tag is v* and you have selected ENVIRONMENT as prod-us in first stage
        stage('US Env') {
            when {
                expression {env.ENVIRONMENT == 'prod_us'}
            }
            steps {
                script {
                    set_Prod_US_Constant_Env() // please do not change this 
                    
                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/prod-us/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:us-east-1:725539715953:targetgroup/sm-tg-conversive-button-management/1b24335b372f1876
                    '''
                }
            }
        }
        // This stage will be executed if tag is v* and you have selected ENVIRONMENT as prod-aus in first stage
        stage('AUS Env') {
            when {
                expression {env.ENVIRONMENT == 'prod_aus'}
            }
            steps {
                script {
                    set_Prod_AUS_Constant_Env() // please do not change this 

                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/prod-aus/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:ap-southeast-2:514231095641:targetgroup/sm-tg-conversive-button-management/76d663d8b83c252a
                    '''
                }
            }
        }
        // This stage will be executed if tag is v* and you have selected ENVIRONMENT as prod-eu in first stage
        stage('EU Env') {
            when {
                expression {env.ENVIRONMENT == 'prod_eu'}
            }
            steps {
                script {
                    set_Prod_EU_Constant_Env() // please do not change this 
                    
                    env.ECS_SERVICES = '''  
                        conversive_button_management_svc
                    '''
                    env.TASK_DEFINITION_FILE_NAMES = '''
                        conversive_button_management_td
                    '''
                    env.TASK_DEFINITION_FILE_PATHS = '''
                        task-definitions/prod-eu/conversive_button_management_td.json
                    '''
                    env.TARGET_GROUP_ARN = '''
                        arn:aws:elasticloadbalancing:eu-west-1:121234700868:targetgroup/sm-tg-conversive-button-management/2c1de98e5ce0a63b
                    '''
                }
            }
        }
        // This stage will build docker image using Dockerfile that you have defined in the gitlab repository
        // This stage will use the GIT_USER_NAME && GIT_AUTH_TOKEN as argument to clone private repository
        // Every time when this stage executes two tags is assigned to docker-image (1st tag: Latest, 2nd tag: Based on environment)
        stage('Build and tag docker image') {
            steps {
                script {
                    BuildAndTagDockerImage()
                }
            }
        }
        // This stage will create ECR Repository if not already exists
        stage('Create ECR Repository') {
            steps {
                script {
                    withAWS(region: "$AWS_DEFAULT_REGION", role: "$ROLE_ARN") {
                        CreateECRRepoIfNotExists()
                    }
                }
            }
        }
        // This stage will be used to login into the ecr repository
        stage('AWS ECR login') {
            steps {
                script {
                    withAWS(region: "$AWS_DEFAULT_REGION", role: "$ROLE_ARN") {
                        LoginAwsEcrRepo()
                    }
                }
            }
        }
        // This stage will be executed if environment is not Integration and QA
        // This stage asks user input and sends email confirmation before deployment
        stage('Deploy') {
            steps {
                script {
                    Deploy()
                }
            }
        }
        // This stage is used to push docker image to ECR Repository
        stage('Pushing build image to ECR') {
            steps {
                script {
                    withAWS(region: "$AWS_DEFAULT_REGION", role: "$ROLE_ARN") {
                        PushImageToECR()
                    }
                }
            }
        }
        // This stage will register the task-definitions each time, if any error comes while registering the task-definitons, you 
        // will be notified here with the actual error, if error comes this stage will be existed with the error message 
        stage('Register ecs-task-definition.json') {
            steps {
                script {
                    withAWS(region: "$AWS_DEFAULT_REGION", role: "$ROLE_ARN") {
                        RegisterECSTaskDef()
                    }
                }
            }
        }

        stage('Modify port of target group to traffic port if it is not already') {
            steps {
                script {
                    withAWS(region: "$AWS_DEFAULT_REGION", role: "$ROLE_ARN") {
                        ModifyPortToTrafficPort()
                    }
                }
            }
        }
        
        // In this stage we will create the target group, alb listener rule , and will created ecs service using cloudformation
        // We have used the cloudformation deploy which will try to create the stack if it exists, it will try to update if anything changes in cloudformation.yaml or parameters.yaml
        stage('deploy cloudformation stack') {
            steps {
                script {
                    withAWS(region: "${AWS_DEFAULT_REGION}", role: "${ROLE_ARN}") {
                        DeployCloudFormationStack()
                    }
                }
            } 
        }

        stage('ECS tasks autoscaling for prod-env') {
            when {
                expression {env.ENVIRONMENT == 'prod_aus' || env.ENVIRONMENT == 'prod_eu' || env.ENVIRONMENT == 'prod_us'}
            }
            steps {
                script {
                    withAWS(region: "${AWS_DEFAULT_REGION}", role: "${ROLE_ARN}") {
                        EcsTasksProdAutoscaling()
                    }
                }
            }
        }
    }
    // This stage will always be executed if pipeline is succeeded, failed, aborted or any other reason
    post {
        always {
            NotifyBuildStatus(currentBuild.currentResult)
            cleanWs deleteDirs: true
        }
    }
}