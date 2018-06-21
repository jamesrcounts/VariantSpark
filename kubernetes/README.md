```bash
docker build -t client .
docker run -it --rm -e MASTER=https://C38D671D7FE9934DB550C25F3EC4D2D2.yl4.us-west-2.eks.amazonaws.com:443 -e INPUT_BUCKET=variant-spark-k-storage20180618203822490200000001 -v ${HOME}/.kube/config:/root/.kube/config client
```
