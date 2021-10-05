FROM python:3.7.4

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client

# copy in base requirements since they're always used, allowing us to cache them
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt --src /usr/local/src

ARG requirefile=requirements.dev.txt

COPY requirements.* ./
RUN pip install --no-cache-dir -r $requirefile --src /usr/local/src

COPY . .

# Environment variables
ENV POSTGRES_HOST=db
ENV POSTGRES_PORT=5432
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=svip_api
ENV DJANGO_SU_NAME=admin.name
ENV DJANGO_SU_EMAIL=admin.email
ENV DJANGO_SU_PASSWORD=admin.password
ENV SOCIBP_BASE_URL=https://xxx:xxxg@socibp.nexus.ethz.ch/
#ENV USE_DEV_SERVER=true

# API port
EXPOSE 8085

CMD [ "/bin/bash", "entrypoint.sh" ]
