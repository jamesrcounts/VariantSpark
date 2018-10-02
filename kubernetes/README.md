# VariantSpark on Kubernetes

In this folder you'll find a code sample which allows you to setup and run the VariantSpark Scala library on an AWS EKS cluster (using Docker and Kubernetes).  The example code includes:
- Terraform templates to build an EKS (Kubernetes) cluster based on custom Docker files
- Two types of pods or nodes
    - Worker nodes which include Spark and Variant Spark
    - Worker node which includes Jupyter and an example notebook
    
NOTE:  The `data` folder contains sample genomic sequencing data that you can use to test the cluster setup with the example Jupyter notebook.

Shown below is the solution architecture.

![VariantSpark on AWS EKS-Kubernetes](/images/VS-eks-aws.png)
VariantSpark is a custom machine learning library written by the team at CSRIO Bioinformatics in Sydney, Australia.  To learn more about VariantSpark, see the source code Repo at this location. https://github.com/jamesrcounts/VariantSpark/tree/spark2.3

Note: VariantSpark requires Spark 2.3 for Kubernetes support.
## Step-by-Step Setup Instructions

 - The page `VS-EKS.md` contains step-by-step instructions to implement this configuration on AWS.
 - Please read the prerequisites carefully and validate both the servcie and version, i.e. **kubernetes 1.10+ or greater...** before running the terraform scripts
 - Remember to shut down the cluster when you are done to avoid unexpected AWS service charges

## Future Work
 - Test with the team at CSIRO (acceptance / usability)
 - Load test with subset of genomic data 
 - Load test with GWAS-scale job

 ### Exploration Areas

 This work is in the initial POC stage.  We have plans for testing in a number of other areas.
 - **Comparison to AWS SageMaker** - run a side-by-side comparison in setup time/cost and also job run time/cost between this configuration and running VariantSpark as a custom ML algorithm on SageMaker  

 - **Test Kubernetes auto-scaling** - step-by-example shown herehttps://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
