# Automating Bank App Deployment to AWS Elastic Beanstalk using Jenkins
## Purpose

This is a continuation from our first deployment found [here in this repository. ](https://github.com/jonwang22/DeployBankAppUsingAWSElasticBeanstalk) The first deployment we did, had a manual step in releasing and deploying our code to AWS Elastic Beanstalk. Summarizing, we downloaded our code in a zip file from Github, unzipped the folder and removed the top level folder, re-zipped the contents with just the files found in the repository, then uploaded it to Elastic Beanstalk.

The purpose of this project is automating the deployment after building and testing in Jenkins to having jenkins deploy to Elastic Beanstalk for us. In order to enable the automation there are a few requirements we need.

* Jenkins needs credentials to access the AWS account we want to deploy our AWS Elastic Beanstalk Environment in.  
* Jenkins needs a way to communicate with the APIs for AWS Elastic Beanstalk
* Jenkins needs to know what commands to execute for the deploy stage after the build and test stage.

At a high level, this project helps us dive deeper into configuring Jenkins to play a bigger role in our CI/CD pipeline. We will be exposed to creating Security Credentials from AWS in the form of ACCESS Keys tied to our IAM User, allowing Jenkins to authenticate into AWS on our behalf to perform the actions needed on our behalf. AWS CLI and EB CLI is needed for Jenkins to execute API calls to Elastic Beanstalk to create our environments to deploy our banking app. 

## Steps Taken to Implement

1. Git clone code repository to personal repository without creating a fork. The reason why we don't want to fork is because we want to have a completely independent copy of the repository, unrelated to the original repository. We can also modify access controls or repository settings that would not be possible if we had forked the original repository.

   * You can do it multiple ways but I chose to use this method https://gist.github.com/hohowin/954fba73f5a02d37e15a6ea5e5b10b54
      - Create empty repo in Github, cannot have any commits.
      - On EC2 instance or local machine, create empty directory and run `git init`
      - Navigate to that empty directory and run `git pull $SOURCE_GITHUB_REPO` for your code
      - Once the source code has been pulled down to your directory, run `git remote add origin $GIT_URL_NEW_CREATED_REPO` and then `git push origin main` (For this, our main branch is called `main`, by default your main branch could be called `master`. Variablized the command looks like this `git push origin $NAME_OF_BRANCH`
        * Git remote essentially creates a link between your local respository to your remote repository hosted in Github.
        
   * The other ways you can clone a repository:
      - Git clone source repository and add a remote link to destination repository.
      - Git clone both source and destination repositories, copy files locally from source repo to destination repo and then git push files in the destination repo.
    
2. Create AWS Access Key for IAM User Authentication. Here we are creating a long term security credential that we will allow Jenkins to use in order to access AWS Resources and APIs. In this case specifically, accessing Elastic Beanstalk and running AWS CLI/EB CLI commands to create our EB environment.

  * Log into AWS Account -> IAM -> Click on IAM User you want to let Jenkins authenticate into AWS -> Create Access Key -> Select "Third-Party Service" because Jenkins is a third party service we are granting permissions. -> Save the Access_Key and Secret_Access_Key as we will need this later on. Download the CSV file containing your keys when prompted.

NOTE: We do not want to ever share these access keys with anyone because with it, anyone can then use these credentials and authenticate as us and perform any actions that our IAM User has permissions for. Since our IAM User has full administrative rights, if someone else obtains our keys, they can do whatever they want via the AWS CLI to our account from creating resources to deleting resources and modifying anything within the account.

3.  Created EC2 Instance to host Jenkins
   
   * Created EC2 Instance in AWS.
   
   * Created a security group that allowed SSH for my personal IP and EC2 Instance Connect, HTTP and custom port 8080 for Jenkins.

4. Installed Jenkins to my Jenkins server and started it up.

   ```
   # Updating existing packages on system, installing fontconfig, java runtime env, software properties common to manage additional software repos. Added deadsnakes PPA and installed python3.7
   sudo apt update && sudo apt install fontconfig openjdk-17-jre software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.7 python3.7-venv

   # Downloaded the Jenkins respository key. Added the key to the /usr/share/keyrings directory
   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

   # Added Jenkins repo to sources list
   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

   # Downloaded all updates for packages again, installed Jenkins
   sudo apt-get update
   sudo apt-get install jenkins

   # Started Jenkins and checked to make sure Jenkins is active and running with no issues
   sudo systemctl start jenkins
   sudo systemctl status jenkins
   ```

5. Create a script to check system resources called `system_resources_test.sh` that checks for system resources (can be memory, cpu, disk, all of the above and/or more) Jenkins build will look for this script.

6. Interact with Jenkins

   * Connected to Jenkins Server via web browser using server's Public IP Address and port 8080
   * Installed recommended plug-ins
   * Created Admin user account
   * Set the Jenkins base URL (Just used the default one provided)
   * Created Multibranch Pipeline within Jenkins  
   * Create a link with Github repo
  
     * Under "Branch Sources", select GitHub. Provide the Github repo link and add your github username and user personal access token for the credentials.
     * To generate your GitHub personal access token. <br><br> Login to Github -> Click Profile picture at top right to open menu -> Click "Settings" -> Look for "Developer Settings" on the left side column of the page -> Click "Personal Access Tokens" to open drop down menu -> Select "Classic" -> Click "Generate New Token" -> Enter password to verify yourself and select the desired settings. <br><br> The settings I selected for this token are the ```repo``` and ```admin:repo_hook``` scopes.
     * Make sure that you validate your credentials and GitHub repo link with the "Validate" button right under the Repo URL field.
     * Verify Build Configuration settings are set to ```Mode: by Jenkinsfile``` and ```Script Path: Jenkinsfile```

   * Started a build.
  
First step: Checkout Source code.
![image](https://github.com/user-attachments/assets/b3b8f108-a155-4771-9496-1c873e8a964c)

Second step: Build Step
![image](https://github.com/user-attachments/assets/314b1492-b6bd-4450-9708-6fbae87c5017)

Third step: Test
![image](https://github.com/user-attachments/assets/ad6ee37e-fca4-45d5-9f17-726ba55f4af2)

7. Setting up our environment in Jenkins User

   * Create password for Jenkins using `sudo passwd jenkins`
   * Switch to Jenkins user, `sudo su - jenkins`

8. Navigate to the workspace environment `cd workspace/$NAME_OF_MULTIBRANCH_PIPELINE`

9. Activate the Python Virtual Environment `source venv/bin/activate`
   //TODO
   * What is a virtual environment? Why is it important/necessary? and when was this one (venv) created?

10. Install AWS EB CLI onto server.

    * `pip install awsebcli` && `eb --version`
   
11. Configure AWS CLI

    * `aws configure`
    * Enter AWS IAM USER Access Key
    * Enter AWS IAM USER Secret Access Key
    * Region: "us-east-1"
    * Output format: json
   
12. Initialize AWS Elastic Beanstalk CLI

    * Run `eb init`
    * Set default region to "us-east-1"
    * Enter an Application Name or leave it as default
    * Select Python3.7
    * Select "no" for code commit
    * Select "yes" for SSH and select a "KeyPair"

13. Add a "Deploy" stage to Jenkinsfile

    * Edit Jenkinsfile to add a deploy stage.
    * Add the following code block AFTER the "Test" Stage.
      ```
      stage ('Deploy') {
          steps {
              sh '''#!/bin/bash
              source venv/bin/activate
              eb create [enter-name-of-environment-here] --single
              '''
          }
      }
      ```
      The final Jenkinsfile should look like this
      ```
      pipeline {
        agent any
          stages {
              stage ('Build') {
                  steps {
                      sh '''#!/bin/bash
                      python3.7 -m venv venv
                      source venv/bin/activate
                      pip install pip --upgrade
                      pip install -r requirements.txt
                      '''
                  }
              }
              stage ('Test') {
                  steps {
                      sh '''#!/bin/bash
                      chmod +x system_resources_test.sh
                      ./system_resources_test.sh
                      '''
                  }
              }
              stage ('Deploy') {
                  steps {
                      sh '''#!/bin/bash
                      source venv/bin/activate
                      eb create AutoDeployBankApp --single
                  }
              }
          }
      }
      ```
    

## System Design Diagram

## Issues/Troubleshooting

1. My main issue was with my system resource script. Trying to get the syntax right 


## Optimization

1. How is using a Deploy Stage in the CI/CD pipeline able to increase efficiency of the business?
2. What issues, if any, can come with automating source code to a production environment?
3. How would you address and/or resolve this?

## Conclusion
