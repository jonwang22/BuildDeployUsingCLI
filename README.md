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
      - Once the source code has been pulled down to your directory, run `git remote add origin $GIT_URL_NEW_CREATED_REPO` and then `git push origin main\master`
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


## System Design Diagram

## Issues/Troubleshooting

## Optimization

1. How is using a Deploy Stage in the CI/CD pipeline able to increase efficiency of the business?
2. What issues, if any, can come with automating source code to a production environment?
3. How would you address and/or resolve this?

## Conclusion
