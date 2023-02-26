




```bash
$ docker build -t nginx-forward-proxy:0.0.1 .
$ docker run --rm -it --entrypoint bash nginx-forward-proxy:0.0.1
$ docker tag nginx-forward-proxy:0.0.1 jameszhan/nginx-forward-proxy:0.0.1
$ docker push jameszhan/nginx-forward-proxy:0.0.1
```