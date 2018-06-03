# psma-admin-bdys-data

A UNIX pipeline to automate working with [PSMA Administrative Boundaries](https://data.gov.au/dataset/psma-administrative-boundaries) data.

- Downloads data from data.gov.au
- Join attributes to geometry (they are separate in upstream)
- Merge states into a single countrywide dataset
- Optionally load into PostgreSQL/PostGIS

Processed outputs can be downloaded from [https://tianjara.net/data/psma-admin-bdys/](https://tianjara.net/data/psma-admin-bdys/).

## Install Dependencies

On Ubuntu/Debian run:

    apt-get install wget unzip parallel jq gdal-bin

## Usage
### All data
To run all steps on all data:

    make

### Single dataset
To only download a single dataset:

    make FILE="documents.zip" download_single

See [whitelist.txt](https://github.com/andrewharvey/psma-admin-bdys-data/blob/master/whitelist.txt) for a list of datasets.

Then unpack and process with:

    make unpack process

### PostgreSQL/PostGIS
To load the processed Shapefile(s) into PostgreSQL/PostGIS, set the [PG environment variables](https://www.postgresql.org/docs/current/static/libpq-envars.html) and run:

    make pgsql

or individually with:

    shp2pgsql -dI data/outputs/shp/FILENAME.shp TABLE_NAME | psql

## Make Targets

These make targets are run as part of `make`, this documents what they do.

- **data/index.json**: Download a machine readable index of all resources available at https://data.gov.au/dataset/psma-administrative-boundaries into `data/index.json`
- **download_all**: Download all PSMA Administrative Boundaries datasets into `data/resources`
- **download_single**: Download a single named dataset into `data/resources`
- **unpack**: Unzips all downloaded datasets into `data/resources_unzip`
- **process**: The source datasets are split into per state files with geometry and attributes in separate files. This stage combines all states together into an Australia wide file and joins all attributes. Outputs to `data/outputs/shp`
- **pack**: Creates `.tar.xz` (defaults to `.tar.xz`, call `./src/pack.sh zip` directly for `.zip`) files of the `data/outputs/shp` files for easy distribution into `data/outputs/xz` (or `data/outputs/zip`)
- **clean**: Removes data/index.json only
- **clean_all**: Removes all downloaded and processed data
- **pgsql**: Load Shapefiles into PostgreSQL/PostGIS

## License

Code licensed under the [ISC license](https://opensource.org/licenses/ISC) per LICENSE.

_Administrative Boundaries ©PSMA Australia Limited licensed by the Commonwealth of Australia under [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)._

## See also

- [https://github.com/iag-geo/psma-admin-bdys](https://github.com/iag-geo/psma-admin-bdys)
