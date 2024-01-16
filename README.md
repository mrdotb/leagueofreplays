# League of Replays

<p align="center">
  <a href="https://plausible.io/">
    <img src="https://raw.githubusercontent.com/mrdotb/leagueofreplays/main/priv/static/images/logo.svg" width="140px" alt="League of Replays" />
  </a>
</p>

## Environment Variables for deployment

| Variable Name      | Description                                         | Required | Default Value |
|--------------------|-----------------------------------------------------|----------|---------------|
| `DATABASE_URL`     | URL to the PostgreSQL database                      | Yes      |               |
| `ECTO_IPV6`        | If database host is IPv6                            | Yes      |               |
| `POOL_SIZE`        | PostgreSQL pool size                                | No       | 10            |
| `RIOT_TOKEN`       | Token to access Riot API                            | Yes      |               |
| `S3_ACCESS_KEY`    | S3 access key                                       | Yes      |               |
| `S3_SECRET_KEY`    | S3 secret key                                       | Yes      |               |
| `S3_ENDPOINT`      | S3 endpoint                                         | Yes      |               |
| `S3_BUCKET`        | S3 base URL                                         | Yes      |               |
| `S3_REPLAY_URL`    | S3 replay URL useful if the bucket is behind a CDN  | Yes      |               |
| `RELEASE_COOKIE`   | The erlang cookie for cluster                       | No       |               |
| `LIBCLUSTER`       | Libcluster enabled                                  | No       | false         |
| `K8_NODE_BASENAME` | Libcluster K8s strategy node basename               | No       |               |
| `K8_SELECTOR`      | Libcluster K8s selector                             | No       |               |
| `K8_NAMESPACE`     | Libcluster K8s namespace                            | No       |               |
| `PHX_SERVER`       | Web server enabled?                                 | No       | false         |
| `SECRET_KEY_BASE`  | Web server secret key base for sessions and cookies | Yes      |               |
| `PHX_PORT`         | Web server port                                     | No       | 4000          |
| `PHX_HOST`         | Web server host                                     | Yes      |               |
| `ADMIN_PASSWORD`   | Web server admin password                           | Yes      |               |
| `SPECTATOR_SERVER` | Spectator server enabled?                           | Yes      |               |
| `SPECTATOR_HOST`   | Spectator server host                               | Yes      |               |
| `SPECTATOR_PORT`   | Spectator server port                               | Yes      |               |
| `SCHEDULER`        | Scheduler enabled?                                  | No       | false         |
| `PRO_SCHEDULER`    | Pro scheduler enabled?                              | No       | false         |
| `OBAN_QUEUE`       | Oban queue enabled?                                 | No       | false         |

## Testing

Remove large binary from vcr_cassettes using jq

```bash
cat test/fixture/vcr_cassettes/ugg.json | jq '.[] |= (if .response.binary == true then .response.body = "g20AAAAA" else . end)'
```
