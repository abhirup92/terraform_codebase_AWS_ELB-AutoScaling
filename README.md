# terraform_codebase_AWS_ELB-AutoScaling
This Piece of terraform code can automate a aws infrastructure automation for ELB with auto scaling 
EC2 instance based on a health cheack for port 3000 where i am running my docker. based on health report of a instance it will increase or decrease the EC2 instances for load balancing.

step1 - set up your terraform in your machine using terraform download birany, unzip it and set your path in bash profile
step2 - install aws cli using below for ubuntu
sudo apt  install awscli
aws configure
set your aws IAM role access key here
step3 - run terraform init
terraform apply

*****
output you will get the ELB DNS value
hit the DNS from anywhere in your machine and you should be good see a hellow world page from ruby on rails packaged in docker.

see the below link for docker with ruby on rails helloworld

https://github.com/abhirup92/rubyONrailsG2

Thank You
Abhirup
abhirup92m@gmail.com
