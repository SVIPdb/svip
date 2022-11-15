FROM python:3.7

WORKDIR /app

RUN apt update && apt install -y postgresql-client

COPY requirements.txt ./
RUN pip --disable-pip-version-check install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt --src /usr/local/src

ARG requirefile=requirements.dev.txt

COPY requirements.* ./
RUN pip install --no-cache-dir -r $requirefile --src /usr/local/src

CMD [ "/bin/bash", "entrypoint.sh" ]
