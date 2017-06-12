# WaterCooler

Example chat application built with [Tokumei](https://hex.pm/packages/tokumei).

## Getting started

```
cd water_cooler
docker-compose up
docker-compose scale web=3
```

Visit http://localhost:8080

```
for i in `docker ps -q`; do echo $i; echo " : "; docker inspect $i | grep -i ipaddress | grep -v null | cut -d ':' -f 2; done
```


## Run tests


```
docker run web mix test
```

## TODO

- use registry
- Add Spec
- Add coverage
- Add live reloading
