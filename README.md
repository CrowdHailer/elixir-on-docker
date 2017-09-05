# WaterCooler

Example chat application built with [Tokumei](https://hex.pm/packages/tokumei).

## Getting started

```
cd water_cooler
docker-compose up -d
docker-compose scale web=3
```

Visit port 8080 on one of the running docker containers

```
for i in `docker ps -q`; do echo $i; echo " : "; docker inspect $i | grep -i ipaddress | grep -v null | cut -d ':' -f 2; done
```


## Run tests


```
docker-compose run web mix test
```

## TODO

- use registry
- Add Spec
- Add coverage
- Add live reloading
