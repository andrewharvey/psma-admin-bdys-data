# Dependencies:
# apt-get install wget unzip parallel jq gdal-bin

all: mirror unpack process

mirror:
	mkdir -p data data/resources
	wget -O data/index.json 'https://data.gov.au/api/3/action/package_show?id=bdcf5b09-89bc-47ec-9281-6b8e9ee147aa'
	cat data/index.json | jq --raw-output '.result.resources[].url' | grep --fixed-strings --file whitelist.txt > data/resource_urls.txt
	wget --timestamping -i data/resource_urls.txt --directory-prefix data/resources

unpack:
	ls -1 data/resources/*.zip | parallel unzip {} -d data/resources_unzip

process:
	./src/process.sh

psql:
	echo shp2pgsql -dI data/outputs/shp/Local\ Government\ Areas\ AUGUST\ 2017.shp lga_aug17 | psql

pack:
	./src/pack.sh
