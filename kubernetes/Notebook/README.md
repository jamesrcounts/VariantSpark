```bash
docker build -t notebook .
docker run -p 8888:8888 -v "$PWD":/home/jovyan/work --rm -it --name notebook notebook
```