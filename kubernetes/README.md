# VariantSpark on AWS EKS (Kubernetes)

Customize & run the provided Terraform scripts to set up a VariantSpark container cluster using AWS EKS (Kubernetes) for these business reasons:  

1. **FAST cluster set up & tear down** - for job runs & load testing
 2. **CONSISTANT cluster configuration** - for reproducibility of research
3. **FLEXIBLE scripts** - configure script parameters for best-fit cluster sizing & cloud vendor selection
4. **SAVE money** - reduce cloud compute service charges by using ephemeral docker containers rather than always on VMs (Virtual Machines).
5. **SIMPLE storage / Data Lake** - all data is stored in S3.  There is NO NEED to set up an Apache Spark (EMR) cluster

There are 3 core client configuration areas which you need to setup in order to use EKS w/VariantSpark:  
- **One-time setup steps** - your client machine requires a number of libraries, plan for up to 2 hours for this initial setup  

- **Per job configuration steps** - your custom cluster sizing cluster (parameters), you can use the Terraform script defaults (i.e. EC2 type, quantity, etc...) or you may update as needed
- **Job run execution steps** - after you've completed the one-time client setup steps, then launching your VariantSpark job on AWS EKS requires only two steps. We also provide a Jupyter client node if you prefer to use this to launch jobs (rather than the command line).

---

## Setup a VariantSpark-k cluster

### 0. SETUP 'one-time only' client steps
- Do steps listed at the BOTTOM of this document
- TIP: Use `us-west-2` (Oregon) -   in `us-east-1` EKS returned an 'out of resources' error message.

### 1. CONFIG Terraform Template files
- Update `main.tf` (line 3) with bucket name - line 6 (IAM user) profile if using something other than `[default]`, and also region (if using something other than `us-west-2`)
 - update `variables.tf` - change profile and region as above
 - update the `variables.tf` in the `\modules\eks\` folder - change the `worker_size` for your EC2 instance sizes

### 2. INIT/RUN Terraform Templates
- Navigate to `/infrastructure/`directory -> Run `terraform init` - (first time only)
- Run `terraform plan -var-file config.tfvars -out /tmp/tfplan` - verify no errors after it's run
- Run `terraform apply "/tmp/tfplan"` - this can take up to 15 minutes

### 3. CONFIGURE Kubernetes  
 - RUN - First Time Only (from terminal) & VERIFY Cluster
    - `mkdir .kube`
    - `cd -`
    - `/Users/lynnlangit/Documents/GitHub/variantspark-k`
    - `cp infrastructure/out/config ~/.kube`  
    - `kubectl cluster-info` - verify a cluster address (URL)

### 4. ADD nodes, dashboard, RBAC
 - RUN `kubectl apply -f out/setup.yaml` from `/infrastructure/` and wait for 'ready' in state to add the resources to your cluster  
 - RUN `kubectl proxy` 
 - CONNECT using this proxy address:
    -`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
    - Leave your terminal window open
    - Leave the Kubernetes dashboard (web page) open

### 5. ADD Jupyter notebook service node

 - OPEN a NEW terminal from this location in your local VariantSpark 2.3 fork `.../kubernetes -> /Notebook` directory  
 - RUN `kubectl apply -f notebook.yml` - to create the notebook service
 - VIEW the Kubernetes Web Dashboard, wait for the new pod to turn GREEN
 -----

## RUN the example VariantSpark-k Jupyter notebook  
Use the Kubernetes Web Dashboard
#### 1. LOGIN to Notebook Service
- Locate the login token for your notebook from the Kubernetes pod log
- Click the service external endpoint link for the notebook service
    - Copy token from URL in log
    - Paste the login token into the Jupyter notebook text box
#### 2. COPY Example Notebooks
 - Go to source - kubernetes -> noteook - upload the notebook using the browser (Jupter) - one level below root (permissions error at top)
 - Update the S3 bucket in the notebook (look in S3 for name - long name with date stamp in the bucket name...)
 #### 3. ADD data to S3
 - Naviage to your S3 bucket that was created during setup
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
    - run `terraform plan -var-file config.tfvars -destroy -out /tmp/tfplan` (verify no errors!)
    - run `terraform apply /tmp/tfplan`
    - verify that this also deleted AWS NLB and AWS VPC
- manually delete s3 buckets with data (optional)
    - VS source data
    - terraform state-storage 

-----

### Other Information and Notes
 - AWS-IAM-Authenticator (was named 'Heptio') tokens time-out, if the connection to the Kubernetes dashboard fails, simply re-fresh the page.

 --------
 ### Future Work
 - Parameterize the Terraform templates to be able to specify the cloud provider.  Currently uses AWS only.
 - Add new capability for AWS EKS 2.0 to support the Kubernetes Horizontal Pod Autoscaler.  See this [link](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for more information.

  ---  
 
----- ONE TIME INSTALLATION STEPS ------------------
1. General Prereqs - TIP: Use `us-west-2` (Oregon),  in `us-east-1` EKS returned an 'out of resources' error message.
   
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
