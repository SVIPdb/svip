USER:=$(shell echo "$$(id -u):$$(id -g)")
/usr/local/share/seqrepo/latest:
	@mkdir -p /usr/local/share/seqrepo	
	@docker-compose run --rm -u $(USER) seqrepo
	@ln -s /usr/local/share/seqrepo/$(find /usr/local/share/seqrepo -type d -maxdepth 1 | sort | tail -1 | sed -E 's,.*\/,,') /usr/local/share/seqrepo/latest
	