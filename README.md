# Elixir on Docker

**Quickly get started developing clustered Elixir applications for cloud environments.**

This project template provides a set of sensible defaults for a new application designed to be cloud native.
It includes:

- A main service `www`, this serves the main content offered by your application.
- Secure HTTP/2 content delivery with [Ace]() web server.
- Code reloading in development environment using [ExSync]().
- Automatic clustering. Setup for [docker-cloud]() other environments coming soon.
- Web based metrics, monitoring and observing with [Wobserver](https://github.com/shinyscorpion/wobserver).
- Documentation driven development with [Raxx.Blueprint]().
- Integration test suit running from the `integration` service.

## Get Started

To use this template docker and docker-compose need to be installed on your machine.

1. Clone this repository.
*Change `project-name` to your projects name.*
```
git clone <url> <project-name>
cd <project-name>
```

2. Delete git history.
```
rm -r .git
```

3. Start all services
```
docker-compose up
```

4. View your running project at http://localhost:8080

### ^^TODO delete this introduction.^^
---

### Run all services

```
docker-compose up
```

*Use `-d` to run in the background.*
*Use `--build` to ensure images are rebuilt.*
*Use `docker-compose down` to stop all services.*

- HTTP endpoint available at: [http://localhost:8080/](http://localhost:8080/)
- HTTPs endpoint available at: [https://localhost:8443/](https://localhost:8443/)
- Wobserver dashboard available at: [http://localhost:4001/](http://localhost:4001/)

### Fetch dependencies

```
docker-compose run www mix deps.get
```

*All mix tasks for a service can be run this way, such as tests for a single service.*

### Run integration tests

```
docker-compose \
-f docker-compose.yml \
-f docker-compose-test.yml \
run integration mix test
```

*The `-c` flag specifies a compose file to use when starting services.*

### Attach iex session

```sh
docker ps
# Find container-id to attach to.

docker exec -it <container-id> sh bin/debug

# in iex shell
iex(debug@<hostname>)1> Node.connect(:"app@<hostname>")
```

### Publish a new image

### TODO

- instructions to tag image
- get started on cloud
- add peer names as a config variable
- move to exposes
