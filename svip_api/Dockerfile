FROM python:3.7.4

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client

# copy in base requirements since they're always used, allowing us to cache them
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --src /usr/local/src

ARG requirefile=requirements.dev.txt

COPY requirements.* ./
RUN pip install --no-cache-dir -r $requirefile --src /usr/local/src

COPY . .

# API port
EXPOSE 8085

CMD [ "/bin/bash", "entrypoint.sh" ]
