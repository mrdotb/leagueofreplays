# Lor

## Testing
Remove large binary from vcr_cassettes using jq

```bash
cat test/fixture/vcr_cassettes/ugg.json | jq '.[] |= (if .response.binary == true then .response.body = "g20AAAAA" else . end)'
```

## Prod env

```bash
PHX_SERVER
DATABASE_URL
SECRET_KEY_BASE
PHX_HOST
PORT
RIOT_TOKEN
ACCESS_KEY
SECRET_KEY
S3_ENDPOINT
S3_BUCKET
S3_URL
LOR_SPECTATOR_HOST
LOR_SPECTATOR_PORT
```
