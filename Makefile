
all: data/index.json download_all unpack process

data/index.json:
	# download an index of all resources at https://data.gov.au/dataset/psma-administrative-boundaries
	mkdir -p data data/resources
	wget -O $@ 'https://data.gov.au/api/3/action/package_show?id=bdcf5b09-89bc-47ec-9281-6b8e9ee147aa'

download_all: data/index.json
	# download all resources
	cat $< | \
	    jq --raw-output '.result.resources[].url' | \
	    grep --fixed-strings --file whitelist.txt | \
	    wget --timestamping --no-http-keep-alive -i - --directory-prefix data/resources

download_single: data/index.json
	# download a single named resource
	# Usage: make FILE="documents.zip" download_single
	cat $< | \
	    jq --raw-output '.result.resources[].url' | \
	    grep --fixed-strings "${FILE}" | \
	    head -n 1 | \
	    wget --timestamping --no-http-keep-alive -i - --directory-prefix data/resources

unpack:
	# unzip
	mkdir -p data/resources_unzip
	ls -1 data/resources/*.zip | parallel unzip {} -d data/resources_unzip
	# remove tab files from source zip as to avoid getting in the way of those we create
	rm -f data/resources_unzip/*/Standard/*_tab.*

process:
	# join attributes to geometry and merge states together
	./src/process.sh

pack:
	./src/pack.sh xz

pgsql:
	./src/loadPgsql.sh

clean:
	rm -rf data/index.json

clean_all:
	rm -rf data
