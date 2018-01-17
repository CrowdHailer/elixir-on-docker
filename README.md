# Elixir on Docker

**Quickly get started developing clustered Elixir applications for cloud environments.**

[See a walkthrough of developing a chat application from this template](http://crowdhailer.me/talks/2017-10-31/live-coded-chat-app-in-45-minutes/)

This project template provides a set of sensible defaults for a new application designed to be cloud native.
It includes:

- A main service `www`, this serves the main content offered by your application.
- Secure HTTP/2 content delivery with [Ace](https://github.com/crowdhailer/ace) web server.
- Code reloading in development environment using [ExSync](https://github.com/falood/exsync).
- Automatic clustering. Setup for [docker-cloud](http://cloud.docker.com/) other environments coming soon.
- Web based metrics, monitoring and observing with [Wobserver](https://github.com/shinyscorpion/wobserver).
- Documentation driven development with [Raxx.ApiBlueprint](https://hex.pm/packages/raxx_api_blueprint).
- Integration test suit running from the `integration` service.

## Get Started

To use this template docker and docker-compose need to be installed on your machine.

### Clone this repository

*Change project-name to your projects name.*

```
git clone <url> <project-name>
cd <project-name>
```

Delete git history.

```
rm -r .git
```

### Fetch dependencies

```
docker-compose run --rm www mix deps.get
```

*All mix tasks for a service can be run this way, such as tests for a single service.*

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


### Run integration tests

```
docker-compose \
-f docker-compose.yml \
-f docker-compose-test.yml \
run integration /bin/bash -c "mix deps.get; mix test"
```

*The `-f` flag specifies a compose file to use when starting services.*

### Attach iex session

```sh
docker ps
# Find container-id to attach to.

docker exec -it <container-id> sh bin/debug

# in iex shell
iex(debug@<hostname>)1> Node.connect(:"app@<hostname>")
```
