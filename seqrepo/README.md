# Seqrepo

This populates the seqrepo resource into `/usr/local/share/seqrepo`. Which is a **requirement** to run `svip_api` as well as the `harvester`.

## Requirements

- Make sure the directory `/usr/local/share/seqrepo` exists and has the required permissions

```bash
sudo mkdir -m 777 /usr/local/share/seqrepo 
```

- Because it can become large please make sure to put it on a location with enough space. I.e. you could create `/usr/local/share/seqrepo` as a symbolic link that points to this location.

```bash
sudo ln -s /path/to/location /usr/local/share/seqrepo
```

## Installation 

You just need to run `make` to populate the seqrepo. This will take a while...

```bash
make
```
