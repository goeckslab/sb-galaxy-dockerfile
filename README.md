## Minimal(ish) Galaxy 23.0 container
A Dockerfile that builds a smallish image running base Galaxy 23.0. Galaxy is served on port `8080`. 

The optional Galaxy configuration parameter `galaxy_url_prefix` can be set by adding the environment variable `PROXY_PREFIX`, as shown below:

```
docker run -p 8080:8080 -e PROXY_PREFIX=/foo/ <tag>
```

... which will serve Galaxy on `<ip address>:8080/foo/`.

For current tags, see:
- https://quay.io/repository/goeckslab/sb-galaxy-23.0?tab=tags