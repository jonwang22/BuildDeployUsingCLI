# Automating Bank App Deployment to AWS Elastic Beanstalk using Jenkins
## Purpose

This is a continuation from our first deployment found [here in this repository. ](https://github.com/jonwang22/DeployBankAppUsingAWSElasticBeanstalk) The first deployment we did, had a manual step in releasing and deploying our code to AWS Elastic Beanstalk. Summarizing, we downloaded our code in a zip file from Github, unzipped the folder and removed the top level folder, re-zipped the contents with just the files found in the repository, then uploaded it to Elastic Beanstalk.

The purpose of this project is automating the deployment after building and testing in Jenkins to having jenkins deploy to Elastic Beanstalk for us. In order to enable the automation there are a few requirements we need.

* Jenkins needs credentials to access the AWS account we want to deploy our AWS Elastic Beanstalk Environment in.  
* Jenkins needs a way to communicate with the APIs for AWS Elastic Beanstalk
* Jenkins needs to know what commands to execute for the deploy stage after the build and test stage.

At a high level, this project helps us dive deeper into configuring Jenkins to play a bigger role in our CI/CD pipeline. We will be exposed to creating Security Credentials from AWS in the form of ACCESS Keys tied to our IAM User, allowing Jenkins to authenticate into AWS on our behalf to perform the actions needed on our behalf. AWS CLI and EB CLI is needed for Jenkins to execute API calls to Elastic Beanstalk to create our environments to deploy our banking app. 

## Steps

1. 

## System Design Diagram

## Issues/Troubleshooting

## Optimization

1. How is using a Deploy Stage in the CI/CD pipeline able to increase efficiency of the business?
2. What issues, if any, can come with automating source code to a production environment?
3. How would you address and/or resolve this?

## Conclusion
