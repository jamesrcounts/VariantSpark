# VariantSpark on AWS EKS (Kubernetes)


### 0a. SETUP 'one-time only' client steps (at bottom of this page)
- TIP: Use AWS region `us-west-2` (Oregon) 

### 0b. CONFIG Terraform Template files (at 12 EC2 x r4.4xlarge) 
 - SET the type (size) of EC2 instances via `worker_size` value at`../modules/eks/variables.tf` line 8
 - SET the number of EC2 instances via  `desired_capacity` & `max_size` values at `../modules/eks/autoscaling-group.tf` lines 46/48  
 - RUN `terraform init` (from `...\infrastructure\`)

### 1a. RUN Terraform Templates from `/infrastructure/`
- RUN `terraform plan -var-file config.tfvars -out /tmp/tfplan`  & VERIFY no errors after it's run
- RUN `terraform apply "/tmp/tfplan"` & WAIT (can take up to 15 minutes) for 'complete'

### 1b. COPY Generated EKS Config File 
 - Do once AFTER the first (initial) run of Terraform 
    - `mkdir .kube`
    - `cp infrastructure/out/config ~/.kube`  

### 2. ADD Kubernetes nodes, dashboard, RBAC from `/infrastructure/`
 - RUN `kubectl apply -f out/setup.yaml` & WAIT for 'ready' 
 - RUN `kubectl proxy` 
 - CONNECT to the Kubernetes web page using this proxy address:  
    - `http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
    - Leave your terminal window open & Kubernetes dashboard (web page) open
   
### 3. ADD Jupyter notebook service node and pod from `.../kubernetes -> /Notebook`

 - OPEN a NEW terminal from a local VS 2.3 fork
 - RUN `kubectl apply -f notebook.yml` - creates the notebook pod
 - VIEW the Kubernetes Web Dashboard & WAIT for the new Jupyter pod to turn GREEN

### 4. KUBERNETES commands - as an alternative viewing the Kubernetes services in the web console, you can use the `kubectl` command(s).  Below is a partial list of commands:
    `kubectl cluster-info` - verifies your EKS cluster address (URL)
    `kubectl proxy` - creates a proxy to the Kubernetes web console
    `kubectl apply -f out/<someSetupFile>.yaml` - applies configuration to cluster
 -----

## RUN example VariantSpark Jupyter notebook(s)  
Using the Kubernetes Web Dashboard...
#### 1. LOGIN to Notebook Service
- LOCATE the Jupyter notebook login token for your notebook from the Kubernetes pod log
- CLICK the service external endpoint link for the notebook service
    - COPY token from URL in log
    - PASTE the login token into the Jupyter notebook text box
#### 2. UPLOAD Example Jupyter Notebooks
 - Go to source - kubernetes -> Noteook - upload the example notebooks using the browser (Jupter) - at root level 
#### 3. RUN VariantSpark analysis
 - View your example notebook, read notebook and RUN  -or-
 - Update notebook lines 29 - 46 for customized job run 
 - View kubernetes dashboard - watch pods get created (red -> green)
     - Wait 3-4 minutes for job to complete
 - Verify job completion in notebook
#### 4. (Optional) ADD your own input data to S3
 - Upload your own data files for analysis to your S3 bucket
 - Update the input data source variable to your S3 bucket name in any sample notebook (look in S3 for name - long name with date stamp in the bucket name...)

 ***TIPS:*** 
 1. STOP a running job
    - Search for the pod which is the 'driver' on the Kubernetes dashboard
    - Kill that pod
    - Wait for all pods in that job to terminate
 2. CONNECT to the Spark Dashboard
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
- from **variantspark** open terminal window
    - stop the Kubernetes web page ('ctrl+c')
    - `terraform plan -var-file config.tfvars -destroy -out /tmp/tfplan` 
        - verify no errors
    - `terraform apply /tmp/tfplan` & WAIT for it to complete (up to 15 min)

-----
 
----- ONE TIME INSTALLATION STEPS ------------------
1. General Prereqs 
   
    a. **AWS account & tools** - create / configure
    - AWS Account  - uses AWS account configured in your `aws cli`
    - AWS IAM user - same as above
    - AWS cli 
        - `aws configure` to verify configuration for `--default` profile
        - could use IAM user with use non-default (named) profile  
        - TIP: Use `us-west-2` (Oregon),  in `us-east-1` EKS returned an 'out of resources' error message.
     - AWS STS - must activate for the region you are using (us-west-2) via IAM console ->Account setting -> STS regions

    b. **Git** - install **git** or **GitHub Desktop**
    - **pull GitHub Repo** `VariantSpark` - git checkout VariantSpark branch 2.3 on jamesrcounts fork of VariantSpark
   

2. Client Service Prereqs (IMPORTANT: instructions for Mac/OSX)

    The client requires particular versions of Terraform, Docker, Kubernetes and Heptio. Also the client install process varies for Windows, Mac or Linux clients.
    Note: all items must be in your client machine's local PATH

| Item                   | Tested Version | OS(s)                    | Verify                   | Link and Notes     |
|------------------------|----------------|--------------------------|--------------------------|--------------------|
| VariantSpark 2.3       | 2.3            | use git                  | checkout branch 2.3      | [link](xxx) - for `*.yml`,`*.yaml` & `*.ipynb` files   |
| aws cli                | 1.15           | Mac, Linux  requires pip | `aws version`            | [link](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)    |
| homebrew (package mgr) | 1.7.1          | Mac (optional)           | `homebrew version`       | [link](https://devhints.io/homebrew) - `brew update` & `brew upgrade`   |
| apt-get (package mgr)  |                | Linux (optional)         | `apt-get`                |   |
| terraform              | 0.11.7         | Mac, Linux               | `terraform version`      | `brew install terraform`    |
| docker                 | 18.06.0-ce     | Community Edition        | `docker version`         | requires account in DockerHub, can also install Kitematic |
| kubernetes             | 1.10+          | Mac, Linux               | `kubectl version`        | [link](https://kubernetes.io/docs/tasks/tools/install-kubectl/), see notes below |
| aws-iam-authenticator  | 1.10.3         | requires kubectl 1.10+   | `aws-iam-authenticator`  | [link](https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator), see notes below|

- **Kubernetes** - Requires version 1.10+ due to IAM requirement, do **NOT** use 'brew install', need latest version from AWS for EKS, install from this link --  

         - Download & Unzip: - `wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt/bin/darwin/amd64/kubectl`
         - Set Permissions: `chmod +x ./kubectl`     
         - Move: `sudo mv ./kubectl /usr/local/bin/kubectl` 
         - Verify install: `kubectl version`

- **AWS-IAM-Authenticator** - Authentication for IAM, required for AWS EKS, see [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html) to install the AWS-IAM-Authenticator for EKS.   
    
        - Download [link](https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator) - IMPORTANT: get the version for your host OS (note: do NOT install using Go-Get as this may install an incorrect version)
        - Configure [link](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
        - Set permissions, add to your local path & verify installed version

### AWS Account Resources

| Item      | Edition        | Quantity                            | Link and Notes|
|-----------|----------------|-------------------------------------|-------------------|
| EC2       | R4.4xlarge     | 4 - cluster 1 to 12                 | scales via auto-scaler, default allocation is 0   |
| EKS       | us-west-2      | not available in all regions        | can configure Kubernetes auto-scaler     |

----
## Variant Spark Job and Kubernetes Cluster Sizing Recommendations

NOTE: This section is "in progress"

1. **Test / First Jobs** - you might consider learning/testing w/Databricks Hipster Index rather than using an AWS EKS cluster.  The Databricks community edition is a much simpler setup and is free for short periods of testing. 
2. **Trial / Small Jobs** - for input data of size xxx and type (csv or vcf), we recommend that you use 2-4 EC2 instances of type M or R (example --- xxxx). This size job uses aaa-bbb number of samples with ccc-ddd number of features.
EMR - 512 instance fleet vs. EKS 8 instances r4.4xlarge
3. **Medium Jobbs** -- for input data of size xxx and type (csv, vcf), we recommend xxx...also you might consider using compression (bz2 is supported). This size job uses aaa-bbb number of samples with ccc-ddd number of features.
4. **Full GWAS (huge jobs)** -- for input data of size xxx and type (csv, vcf), we recommend xxx...also you might consider using conversion (parquet), data paritioning (xxx), and/or compression (bz2 is supported). This size job uses aaa-bbb number of samples with ccc-ddd number of features.

| Job       | Size           | Data                  | Samples * Features |  Recomendation                                                |
|-----------|----------------|-----------------------|--------------------|---------------------------------------------------------------|
| Tiny/Test | M-type         | vcf,csv               | 1,000 * xxx        | Use Databricks Free Community Edition - HipsterIndex Notebook |
| Small     | m4 or r4       | vcf,csv, bz2          | 5,000 * 2,5M       | Use AWS - EKS or EMR                                          |
| Huge 1    | m4.4x or r4.4x | parquet, partitioned  | 5,000 * 100M       | Use AWS - EKS w/ auto-scaler or EMR (spot fleet)              |
| Huge 2    | m4.4x or r4.4x | parquet, partitioned  | 10,000 * 50M       | Use AWS - EKS w/ auto-scaler or EMR (spot fleet)              |

5. **Spark Parameter settings** - by default Spark uses 1 GB / RAM per executor.  Configure the number of Spark executors xxx and the RAM per executor for bigger jobs using the VariantSpark Spark input parameters.
6. **VariantSpark Parameters settings** - VariantSpark includes a large number of configurable parameters, for more information, go here - link
----
## Troubleshooting

1. **Create Cluster Error**

    Problem: Incorrect version of Kubernetes  
    Solution: Delete incorrect version and re-install (if using GCP SDK, may have to delete that SDK as it contains a version Kubernetes)
    Problem: Not enough resources EC2 instances of this type  
Solution: Terraform destory/Terraform apply.  Send request to AWS to increase resources

    Problem: Out of EIP addresses, etc... in your AWS Account  
Solution: Terraform destory/Terraform apply.  Manually delete AWS VPC / EC2 resources tagged with 'variant-spark'

    Problem: Instance profile error on attempt to creat the cluster.  If you delete an IAM role, there is associated instance metadata that is NOT viewable in the AWS console.  
     Verification: - `aws iam list-instance-profiles` to view any instance data   
     Solution: delete orphaned instance profiles -  `aws iam delete-instance-profile --instance-profile-name profile_name_here`.

    Problem: Not enough EKS resources available.  
Solution: Terraform destory/Terraform apply. Use AWS regaion `us-west-2`

    Problem: Jupyter notebook pod never turns green - stays red.  
Solution: - `kubectl delete -f notebook.yml` & re-run `kubectl apply -f notebook.yml`

    Problem: The connection to the Kubernetes dashboard fails, (the AWS-IAM-Authenticator tokens will time-out)   
    Solution: Refresh the web page to generate a new token.

2. **Job Runs Slowly Error**  

    Problem: Not enough memory in EKS cluster to load all data into memory for processing  
Verification: Use Spark Console -> Storage to verify xx% of data in storage (cached), should be 100%    
Solution: Add more/larger EC2 instances to cluster and configure Spark executor qty and size to use 85% + of available memory

    Problem: One or more Spark Executors runs slowly and/or appears to be 'stuck'  
Verification: Use Spark Console -> Job Steps / Executors to verify executor state, look for long green bar and/or executor w/0 data  
Solution: Stop job and re-run

    Problem: Job runs slowly  
    Verification: Use `kubectl` commands to examine cluster operations.  
    List of common `kubectl` commands [link](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-context-and-configuration)   
    Solutions: Re-size cluster, kill long-running tasks/pods/node manually, re-start job  

    Problem: Job appears to be complete, but does not return a '0' code (stays in running state)  
Verification: Review log from Spark driver for this job  
Solution: Stop job and re-run

3. **Job returns non-meaningful results**  

    Problem: No value is returned for OOB error  
    Verification: Spark Driver log returns NaN for oob  
    Solution: Configure -ro paramter for job, this value turns on oob feature (off by default)

    Problem: Results not useful  
    Verification: xxx  
    Solution: Configure -rn value to set a higher number of trees

    Problem: Results not useful 
    Verification: xxx  
    Solution: Configure -rmtry value to set a higher value for mtry

    Problem: Results not useful    
    Verification: xxx  
    Solution: Configure -rbs value to set a higher value for batch size

    Problem: Results not useful   
    Verification: xxx  
    Solution: Configure xxx value to set a higher value for depth of each tree

    Tip: see VariantSpark paramter documenation for more information at [link](https://github.com/jamesrcounts/VariantSpark/blob/spark2.3/README.md) - see bottom of page.

---------

 ### Future Work
 - Test with the updated AWS EKS base image (v24) - [link](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html)
 - Fix the permissions on the EBS volume with public access which holds these files: *.yaml and *.ipynb (examples) for the Jupyter notebook pod
 - Add EKS 2.0 auto-scaler to templates - more at [link](https://aws.amazon.com/blogs/opensource/horizontal-pod-autoscaling-eks/). Supports Kubernetes Horizontal pod auto-scaler.
 - Parameterize the Terraform templates to be able to specify the cloud provider.  Currently uses AWS only.
 





