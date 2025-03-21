# home-server

## What is this about?
Make use of old PC for home server.

Include setup of:
- Nginx-Proxy (proxy)
- ACME-Companion (creation/renewal of Let's Encrypt certificates) 
- Dashboard with nginx (on domain root)
- Grafana (on grafana subdomain)
- Prometheus (not exposed, used from Grafana through internal network)
- CAdvisor (not exposed, used from Prometheus through internal network)
- Node-exporter (not exposed, used from Prometheus through internal network)
- Blackbox-exporteer (not exposed, used from Prometheus through internal network)
- QBitTorrent (on qbittorrent subdomain)
- File Browser (on files subdomain)
- Plex (on plex subdomain)
- Calibre (on calibre subdomain)
- FreshRSS (on freshrss subdomain)
- PiHole (on pihole subdomain)
- WireGuard (on vpn subdomain)
- PostgeSQL (not exposed, used through internal network)
- Keycloak (on auth subdomain)
## Prepare
Adjust the .env file content by setting the base folder, domain, and secrets, or create a new file named .env.server and use it instead.

## Start the bundle
```
docker compose --env-file .env.server up -d
```
## Stop the bundle
```
docker compose --env-file .env.server down
```

## Server preparation and maintenance

Details on [preparation](doc/installation.md) and [maintenance](doc/maintenance.md).


## Acknowledgements

- Monitoring stack: https://github.com/oijkn/Docker-Raspberry-PI-Monitoring
- Grafana dashboard: https://grafana.com/grafana/dashboards/15120
