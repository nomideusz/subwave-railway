FROM ghcr.io/perminder-klair/subwave-aio:1.16.0

# Caddy listens on $CADDY_HTTP_PORT (Railway's PORT, see railway-entrypoint.sh).
# Railway's edge reaches the container from 100.64.0.0/10 and sends
# X-Forwarded-For "<client>, <edge>". The stock AIO Caddy trusts no proxy, so it
# replaces that header with the edge's address and the controller (which keys
# request cooldowns, like dedup and the admin lockout on the leftmost XFF entry)
# sees every listener as one IP. Trusting the edge range keeps the client first.
RUN sed -i -e 's|^:80 {$|:{$CADDY_HTTP_PORT:80} {|' \
      -e 's|^\tauto_https off$|\tauto_https off\n\tservers {\n\t\ttrusted_proxies static 100.64.0.0/10\n\t}|' /etc/caddy/Caddyfile \
 && grep -q '^:{$CADDY_HTTP_PORT:80} {$' /etc/caddy/Caddyfile \
 && grep -q 'trusted_proxies static 100.64.0.0/10' /etc/caddy/Caddyfile \
 && caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint
ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
