The files in this directory are nightly snapshots of the metadata
for datasets published at data.austintexas.gov

There are two kinds of files: catalog files and summary files.


catalog files
-------------

	The catalog files are full dumps of all the metadata for all the
	datasets published on the data portal. It allows for detailed
	analysis of the datasets. Each file contains a JSON object
	with elements:

	* count: number of data catalogs
	* searchType: "views"
	* host: "data.austintexas.gov"
	* timestamp: time at which pull occurred, integer seconds since epoch
	* results: array of catalog metadata, one entry per dataset

	The "results" are produced by the Socrata "/api/search/views" endpoint.


summary files
-------------

	Each catalog file is processed into a summary file, which contains
	a reduced portion of the information that should be sufficient
	for summary analysis. The elements in the summary file are

	* count: number of data catalogs
	* searchType: "views"
	* host: "data.austintexas.gov"
	* timestamp: time at which pull occurred, integer seconds since epoch
	* datasets: generated from the "results" list in the catalog file

The dumper tool is here:
https://github.com/chip-rosenthal/pull-data-portal-catalog
