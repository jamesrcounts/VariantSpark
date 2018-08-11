## VariantSpark-EKS (AWS Kubernetes) Setup Process

Using the provided Terraform scripts to set up a Kubernetes VariantSpark cluster on AWS provides these benefits:
- Quick cluster set up and tear down - for job runs and load testing
- Consistant cluster configuration - for reproducibility of research
- Parameterized scripts - for flexibility in cluster sizing and vendor selection
- Cost savings - more efficient use of cloud compute resources (than VMs)

There are three core aspects to use EKS w/VariantSpark. These are as follows:  - One-time setup steps - client machines require a number of libraries, plan for up to 2 hours for this initial setup
- Per job configuration steps - sizing your cluster and configurating parameters, you may choose to run with Terraform script default cluster sizes (i.e. EC2 type, quantity, etc...) or you may update as needed
- Job run steps - launching VariantSpark on AWS EKS requires only two steps, we provide a connected Jupyter client if you wish to use this to launch jobs
 --- 

----- ONE TIME INSTALLATIONS ----
1. General Prereqs
   
    a. **AWS account & tools** - create / configure
    - AWS Account  (currently using lynnlangit's demo AWS account)
    - AWS IAM user (currently using lynnlangit's demo IAM user)
    - AWS cli 
        - run `aws configure` to verify configuration for `--default` profile
        - could use IAM user with use non-default (named) profile  

    b. **Git** - install **git** or **GitHub Desktop**
    - **pull GitHub Repos** `VariantSpark -k` and `VariantSpark`
    - IMPORTANT: pull VS branch for Spark 2.3 on Jim's fork) repos from GitHub 

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

## To Setup a VariantSpark-k cluster

We are running in `us-west-2` (Oregon).  AWS EKS is only available in `us-west-2` or `us-east-1` currently.   
NOTE: When we tested on `us-east-1`, we got 'out of resources' errors messages from EKS.

### 1. Prepare the S3 bucket     
- create AWS s3 bucket in us-west-1 (should be in same region as cluster, currently using `us-west-2`,) note the bucket name - this will hold the Terraform state file  -> **1-time step**

### 2. Update the Terrform Templates
- update `main.tf` (line 3) with bucket name - line 6 (IAM user) profile if using something other than `[default]`, and also region (if using something other than `us-west-2`)
 - update `variables.tf` - change profie and region as above

### 3. Prepare and run Terraform Templates
- navigate to `/infrastructure/`directory -> 

- run `terraform init` - (first time only)
- run `terraform plan -var-file config.tfvars -out /tmp/tfplan` - verify no errors after it's run
- run `terraform apply "/tmp/tfplan"` - this can take up to 15 minutes

### 4. Verify kubernetes cluster
    --- First Time Only (below) ---
    - from your terminal `cd`
    - then `mkdir .kube`
    - then `cd -`
    - then `/Users/lynnlangit/Documents/GitHub/variantspark-k`
    - then `cp infrastructure/out/config ~/.kube`  
    --- First Time Only (above) ---

 - from your open terminal run `kubectl cluster-info` 
    - you should see a cluster address
    - you can also look in AWS EC2 to see two running instances

### 5. Add the nodes, dashboard, RBAC
 - run `kubectl apply -f out/setup.yaml` from `/infrastructure/` and wait for 'ready' in state to add the resources to your cluster
 - run `kubectl proxy` 
    - connect using this proxy address:
    -`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
- **IMPORTANT** 
    - leave your terminal window open
    - leave the Kubernetes dashboard (web page) open

### 6. Add the Jupyter notebook service

 - open a NEW terminal from this location in your local VariantSpark 2.3 fork `.../kubernetes -> /Notebook` directory 
 - run `kubectl apply -f notebook.yml` - to create the notebook service
 - go to Kubernetes web dashboard 
 - wait for the new pod to turn green
 -----

## Run the example VariantSpark-k Jupyter notebook  
On the Kubernetes Dashboard
#### 1. Login to Notebook Service
- locate the login token for your notebook from the Kubernetes pod log
- click the service external endpoint link for the notebook service
    - copy token from URL in log
    - paste the login token into the Jupyter notebook text box
#### 2. Copy Example Notebook
 - go to source - kubernetes -> noteook - upload the notebook using the browser (Jupter) - one level below root (permissions error at top)
 - update the S3 bucket in the notebook (look in S3 for name - long name with date stamp in the bucket name...)
 #### 3. Add data to S3
 - naviage to your S3 bucket that was created during setup
 - upload data files for analysis 
#### 4. Run VariantSpark analysis
 - View your example notebook, read notebook and RUN  -or-
 - Update notebook lines 29 - 46 for customized job run 
 - View kubernetes dashboard - watch pods get created (red -> green)
     - wait 3-4 minutes for job to complete
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

## Tear Down the Cluster

- from the **VariantSpark** open terminal window
    - `kubectl delete -f notebook.yml` -> deletes the services (& pods)
        - verify that this also deleted AWS NLB and AWS VPC
- from **variantspark-k** open terminal window
    - `terraform plan -var-file config.tfvars -destroy -out /tmp/tfplan` (verify no errors!)
    - `terraform apply /tmp/tfplan`
- manually delete s3 buckets with data (optional)
    - state-storage and data

-----

### Other Information and Notes
 - Heptio tokens time-out, if the connection to the Kubernetes dashboard fails, simply re-fresh the page.
