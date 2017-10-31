version: '3.1'

services:
    fn:
      image: fnproject/functions
      restart: always
      privileged: true
      links:
         - db
      environment:
              - DB_URL=postgres://funcs:funcs@db/funcs?sslmode=disable
              - MQ_URL=redis://redis:6379
              - ZIPKIN_URL=http://zipkin:9411/api/v1/spans
      ports:
           - 80:8080
      volumes:
         - /var/run/docker.sock:/var/run/docker.sock
      depends_on:
           - db
           - redis
           - zipkin
    fn-ui:
      image: fnproject/ui
      restart: always
      ports:
         - 4000:4000
      environment:
            - API_URL=http://fn:8080
    db:
      image: postgres:10
      restart: always
      environment:
            POSTGRES_PASSWORD: funcs
            POSTGRES_USER: funcs
            POSTGES_DB: funcs
    adminer:
        image: adminer
        restart: always
        ports:
           - 8080:8080
        depends_on:
           - db
      
    zipkin:      
      image: openzipkin/zipkin
      ports:
           - 9411:9411
    redis:
        image: redis
        restart: always
    prometheus:
        image: prom/prometheus
        ports:
          - 9090:9090
        volumes:
          - ./prometheus.yml:/etc/prometheus/prometheus.yml
    grafana:
        image: grafana/grafana
        links:
           - fn
        ports:
           - 3000:3000
        environment:
           - GF_SERVER_ROOT_URL=http://blockchain1.cloud.smals.be
           - GF_SECURITY_ADMIN_PASSWORD=secret

           - 8080:8080
        depends_on:
           - db
    
