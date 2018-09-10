# VariantSpark on AWS EKS (Kubernetes)


### 0. SETUP 'one-time only' client steps
- COMPLETE steps listed at the BOTTOM of this document
- USE `us-west-2` (Oregon) 

### 1. CONFIG Terraform Template files
 - UPDATE the `variables.tf` in the `\modules\eks\` folder 
 - CHANGE the `worker_size` value for your EC2 instance sizes

### 2. INIT/RUN Terraform Templates
- GO to `/infrastructure/`  
- RUN `terraform init` - (first time only)
- RUN `terraform plan -var-file config.tfvars -out /tmp/tfplan` 
    - VERIFY no errors after it's run
- RUN `terraform apply "/tmp/tfplan"` 
    - WAIT - this can take up to 15 minutes

### 3. CONFIGURE Kubernetes  
 - RUN - First Time Only (from terminal) & VERIFY Cluster
    - `mkdir .kube`
    - `cp infrastructure/out/config ~/.kube`  
    - `kubectl cluster-info` - verify a cluster address (URL)

### 4. ADD nodes, dashboard, RBAC
 - RUN `kubectl apply -f out/setup.yaml` from `/infrastructure/` 
    - WAIT for 'ready' in state to add the resources to your cluster  
 - RUN `kubectl proxy` 
 - CONNECT using this proxy address:
    -`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
    - Leave your terminal window open
    - Leave the Kubernetes dashboard (web page) open

### 5. ADD Jupyter notebook service node

 - OPEN a NEW terminal from a local VS 2.3 fork `.../kubernetes -> /Notebook` directory  
 - RUN `kubectl apply -f notebook.yml` - to create the notebook service
 - VIEW the Kubernetes Web Dashboard
    - WAIT for the new Jupyter pod to turn GREEN
 -----

## RUN example VariantSpark Jupyter notebook(s)  
Use the Kubernetes Web Dashboard
#### 1. LOGIN to Notebook Service
- LOCATE the Jupyter notebook login token for your notebook from the Kubernetes pod log
- CLICK the service external endpoint link for the notebook service
    - COPY token from URL in log
    - PASTE the login token into the Jupyter notebook text box
#### 2. COPY Example Notebooks
 - Go to source - kubernetes -> noteook - upload the notebook using the browser (Jupter) - one level below root (permissions error at top)
 - Update the S3 bucket in the notebook (look in S3 for name - long name with date stamp in the bucket name...)
 #### 3. ADD analysis source data to S3
 - Navigate to your S3 bucket that was created during setup
 - Upload data files for analysis 
#### 4. RUN VariantSpark analysis
 - View your example notebook, read notebook and RUN  -or-
 - Update notebook lines 29 - 46 for customized job run 
 - View kubernetes dashboard - watch pods get created (red -> green)
     - Wait 3-4 minutes for job to complete
 - Verify job completion in notebook

 ***TIPS:*** 
 1. To stop a running job
    - Search for the pod which is the 'driver' on the Kubernetes dashboard
    - Kill that pod
    - Wait for all pods in that job to terminate
 2. To connect to the Spark Dashboard
    - Start a VariantSpark-k job run
    - Search for the pod which is the 'driver' on the Kubernetes dashboard
    - Proxy - `kubectl port-forward <driver-pod-name> 4040:4040`
    and LEAVE that terminal window open
    - Access the Spark dashboard, while the job is running at `http://localhost:4040`

***IMPORTANT:*** At this time, due to security simplification at this phase, you must DOWNLOAD your notebook, BEFORE you terminate your kubernetes cluster 

----

## DELETE a VS-k Cluster

- from the **VariantSpark** open terminal window
    - `kubectl delete -f notebook.yml` -> deletes the Jupyter service (& pods)
- from **variantspark-k** open terminal window
    - stop the Kubernetes web page ('ctrl+c')
    - run `terraform plan -var-file config.tfvars -destroy -out /tmp/tfplan` 
        - verify no errors
    - run `terraform apply /tmp/tfplan`

-----

### Other Information and Notes
 - AWS-IAM-Authenticator (was named 'Heptio') tokens time-out, if the connection to the Kubernetes dashboard fails, simply re-fresh the page.

 --------
 ### Future Work
 - Parameterize the Terraform templates to be able to specify the cloud provider.  Currently uses AWS only.
 - Add new capability for AWS EKS 2.0 to support the Kubernetes Horizontal Pod Autoscaler.  See this [link](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for more information.

  ---  
 
----- ONE TIME INSTALLATION STEPS ------------------
1. General Prereqs 
   
    a. **AWS account & tools** - create / configure
    - AWS Account  (currently using lynnlangit's demo AWS account)
    - AWS IAM user (currently using lynnlangit's demo IAM user)
    - AWS cli 
        - run `aws configure` to verify configuration for `--default` profile
        - could use IAM user with use non-default (named) profile  
        - TIP: Use `us-west-2` (Oregon),  in `us-east-1` EKS returned an 'out of resources' error message.

    b. **Git** - install **git** or **GitHub Desktop**
    - **pull GitHub Repos** `VariantSpark -k` and `VariantSpark`
    - IMPORTANT: pull VS branch for Spark 2.3 on Jim's fork) repos from GitHub 
    - NOTE: Replace this step with a persistent EBS volume with public access which holds these files:
    *.yaml and *.ipynb (examples)

2. Client Service Prereqs (IMPORTANT: instructions for Mac/OSX)

    The client requires particular versions of Terraform, Docker, Kubernetes and Heptio. Also the client install process varies for Windows, Mac or Linux clients.  These instructions are for Mac clients

    - **0. Homebrew** - install and update package manager
        - install homebrew (then `brew update` & then `brew upgrade`)
        - this may take 10-15 minutes
    - **1. Terraform** - `brew install terraform` - use Terraform 11.7 or greater 
    - **2. Docker** - can get Kitematic (GUI for Docker as well), use Docker 18.06 or greater
    - **3a. Kubernetes** - Requires version 1.10+ due to IAM requirement, do **NOT** use 'brew install', need latest version from AWS for EKS, install from this link --  

         - Download: `wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl`  

         - Unzip: unzip if needed

         - Set Permissions: `chmod +x ./kubectl`     
        
         - Move: `sudo mv ./kubectl /usr/local/bin/kubectl` 

         - Verify install: `kubectl version`

        NOTE:  If you have an older version of Kubernetes, you should delete that directory to avoid version conflict (for example you may need to delete `\gcloud` (sdk) )  

    - **3b. AWS-IAM-Authenticator** - Authentication for IAM, required for AWS EKS, see [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) to install the AWS-IAM-Authenticator for EKS.   
    
        NOTES: 
         - get the version for your host OS
         - do NOT install using Go-Get

        - Download: `https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator`

        - Set Permissions: 
        - Set path:
        - Verify install:

    **Important** to verify the version of Kubernetes 1.10+, which is needed to interoperate with another requirement, which is to use Heptio/AWS IAM with EKS.  You should verify the following text after you run `kubectl version` :   
     
        `Client Version: version.Info{Major:"1", Minor:"11",...`  

-------
## Dependency Versions

Note: all items must be in your client machine's local PATH

| Item                   | Tested Version | OS(s)                               | Link and Notes|
|------------------------|----------------|-------------------------------------|-------------------|
| aws cli                | 1.15           | Mac, Linux    requires pip          |[link](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)    |
| terraform              | 0.11.7         | xx                                  | xx     |
| docker                 | 18.06.0-ce     | Community Edition                   | requires account in DockerHub |
| kubernetes             | 1.10+          | xx                                  | xx |
| aws-iam-authenticator  | xx             | requires kubectl 1.10+              | [link](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)|

### AWS Account Resources

| Item      | Edition        | Quantity                            | Link and Notes|
|-----------|----------------|-------------------------------------|-------------------|
| EC2       | R4.4xlarge     | 4 - cluster 1 to 8                  | scales via auto-scaler, default allocation is 0   |
| EKS       | us-west-2      | not available in all regions        | can configure Kubernetes auto-scaler     |

----
## Troubleshooting

Instance profile error on attempt to creat the cluster.  If you delete an IAM role, there is associated instance metadata that is NOT viewable in the AWS console.  Run `aws iam list-instance-profiles` to view any instance data and, if needed, delete orphaned instance profiles using 
this command `aws iam delete-instance-profile --instance-profile-name profile_name_here`.
