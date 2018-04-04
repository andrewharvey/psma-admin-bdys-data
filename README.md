# psma-admin-bdys-data

Scripts to automate working with [PSMA Administrative Boundaries](https://data.gov.au/dataset/psma-administrative-boundaries) data.

## Install Dependencies

Debian:

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

## Make Targets

- **data/index.json**: Download a machine readable index of all resources avaliable at https://data.gov.au/dataset/psma-administrative-boundaries into `data/index.json`
- **download_all**: Download all PSMA Administrative Boundaries datasets into `data/resources`
- **download_single**: Download a single named dataset into `data/resources`
- **unpack**: Unzips all downloaded datasets into `data/resources_unzip`
- **process**: The source datasets are split into per state files with geometry and attributes in seperate files. This stage combines all states together into an Australia wide file and joins all attributes. Outputs to `data/outputs/shp`
- **pack**: Creates `.tar.xz` files of the `data/outputs/shp` files for easy distribution
- **clean**: Removes data/index.json only
- **clean_all**: Removes all downloaded and processed data

To load the processed shapefiles into PostgreSQL use:

    shp2pgsql -dI data/outputs/shp/FILENAME.shp TABLE_NAME | psql

## License

Code licensed under the [ISC license](https://opensource.org/licenses/ISC) per LICENSE.

_Administrative Boundaries ©PSMA Australia Limited licensed by the Commonwealth of Australia under [Creative Commons Attribution 4.0 International licence (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)._

## See also

- [https://github.com/iag-geo/psma-admin-bdys](https://github.com/iag-geo/psma-admin-bdys)
