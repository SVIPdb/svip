FROM python:3

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --src /usr/local/src

COPY . .

# API port
EXPOSE 8085

CMD [ "/bin/bash", "entrypoint.sh" ]
