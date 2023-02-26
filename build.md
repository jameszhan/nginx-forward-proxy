




```bash
$ docker build --build-arg https_proxy="https_proxy=http://192.168.1.5:3128" -t nginx-forward-proxy:0.0.2 .
$ docker run --rm -it --entrypoint bash nginx-forward-proxy:0.0.2
$ docker tag nginx-forward-proxy:0.0.2 jameszhan/nginx-forward-proxy:0.0.2
$ docker push jameszhan/nginx-forward-proxy:0.0.2
```