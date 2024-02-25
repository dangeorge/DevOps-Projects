# Django-app-on-EC2-using-Jenkins-pipeline
Django note app on EC2 using Jenkins pipeline

![image](https://github.com/dangeorge/Django-app-on-EC2-using-Jenkins-pipeline/assets/5060367/817c9a48-5a59-4367-b07b-7a90a64424de)


This project involves deploying a Django notes app on an EC2 instance using Jenkins declarative CI/CD pipeline.

1. Use Terraform to create key pair, security group and EC2 instace.
2. Use Ansible to install docker, docker-compose, openjdk-17-jre and Jenkins
3. Create Jenkins pipeline to use pipeline script from SCM
4. Placed the Jenkinsfile in the git repository.
5. Create a new pipeline in Jenkins. Tick Github project in General section and add the repository url. Then tick GitHub hook trigger for GITScm polling
6. Add webhook from git repository settings.
