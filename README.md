<p align="center">
  <a href="https://leagueofreplays.co/">
    <img src="https://raw.githubusercontent.com/mrdotb/leagueofreplays/main/priv/static/images/logo.svg" width="140px" alt="League of Replays" />
  </a>


  <h3 align="center">League of Replays</h3>

  <p align="center">
    Record and replay league of legends game.
    <br />
    <a href="https://youtu.be/vXCb2LyK_gg">Youtube demo</a>
    .
    <a href="https://github.com/mrdotb/leagueofreplays/issues">Report Bug</a>
    ·
    <a href="https://github.com/mrdotb/leagueofreplays/issues">Request Feature</a>
  </p>
</p>

### Built With

Leagueofreplay is proudly powered by Phoenix and Elixir.

* [![Phoenix][Phoenix]][Phoenix-url]
* [![Elixir][Elixir]][Elixir-url]
* [![Tailwind][Tailwind]][Tailwind-url]

## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

To run leagueofreplays on your local environment you need to have:
* Postgres
* Elixir
* Erlang
* NodeJS

### Using Docker Compose

A Docker Compose [reference file](https://github.com/mrdotb/leagueofreplays/blob/main/docker-compose.yml) is provided in the repository. You can use it to run leagueofreplays with Docker Compose.

```sh
git clone https://github.com/mrdotb/leagueofreplays.git
cd leagueofreplays
cp .env.sample .env
```

Get your riot token on [developer.riotgames.com](https://developer.riotgames.com/).
Add the token to the `.env` file on `RIOT_TOKEN`

```sh
docker compose --env-file .env up
```

### How to Dev ?

This project use asdf with the following [`tool-versions`](https://github.com/mrdotb/leagueofreplays/blob/main/.tool-versions).

Install [asdf](https://asdf-vm.com/guide/getting-started.html) and the differents plugins.

```sh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

Install [docker](https://docs.docker.com/engine/install/) and [docker compose](https://docs.docker.com/compose/install/)

Clone the repo

```sh
git clone https://github.com/mrdotb/leagueofreplays.git
```

Then you can use install the elixir / erlang / nodejs version.

```sh
asdf install
```
Run postgres and minio

```sh
docker compose -f docker-compose.dev.yml up
```

Install project deps

```sh
npm i --prefix assets
mix deps.get
```

Run project
```sh
iex -S mix phx.server
```

### Configuration

You can find the env configuration [here](https://github.com/mrdotb/leagueofreplays/blob/main/doc/env.md).

### Inspirations

Thanks to [lol-replay](https://github.com/1lann/lol-replay), [UGG](https://u.gg) and [league of graphs](https://www.leagueofgraphs.com/)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Elixir]: https://img.shields.io/badge/elixir-4B275F?style=for-the-badge&logo=elixir&logoColor=white
[Elixir-url]: https://elixir-lang.org/
[Tailwind]: https://img.shields.io/badge/tailwind-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white
[Tailwind-url]: https://tailwindcss.com/
[Phoenix]: https://img.shields.io/badge/phoenix-f35424?style=for-the-badge&logo=&logoColor=white
[Phoenix-url]: https://www.phoenixframework.org/
