
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;

    upstream screwdriver {
        server 127.0.0.1:8080;
    }

    server {

        listen       9000;
        server_name  127.0.0.1;

        charset utf-8;

        root <DEVELOPMENT_DIST>;

        #access_log  logs/host.access.log  main;

        location / {
            try_files $uri @fallback;
        }

        location ~/validate/([0-9a-f]{7,40}) {
            set            $memcached_key "$1";
            memcached_pass host:11211;
            error_page     404 502 504 = @fallback;
        }

        location /api/ {
            rewrite /api/(.*) /$1 break;
            proxy_pass  http://127.0.0.1:8080;
        }

        location @fallback {
            proxy_pass     http://screwdriver;
        }

    }

}
