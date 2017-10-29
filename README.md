# WaterCooler

Cloud native chat application built with Elixir.

Set up as an example application to deploy to docker cloud environments

### Features

- Automatic clustering when deployed on docker-cloud
- TLS(ssl) certificates stored in docker-compose secrets
- Surface/integration testing.

## Getting started

```
docker-compose up
```

Visit [http://localhost:8080/](http://localhost:8080/)

## Run integration tests

```
docker-compose run integration mix test
```

## Connect iex session

```sh
$ docker exec -it <container-id> sh debug

# iex shell
iex(debug@<hostname>)1> Node.connect(:"app@<hostname>")
```
