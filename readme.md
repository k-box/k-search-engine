[![Build Status](https://travis-ci.org/k-box/k-search-engine.svg?branch=master)](https://travis-ci.org/k-box/k-search-engine)

# K-Search Engine Docker image

The K-Search Engine is a [SOLR](https://lucene.apache.org/solr/) instance specifically configured for the [K-Search component](https://github.com/k-box/k-search) to allow full text retrieval of documents.

## Usage

```
# Pull the image
docker pull docker.klink.asia/images/k-search-engine:{version-tag}

# Run the image one time, in this case pressing Ctrl+C will stop the container and remove it
docker run -it --rm -p "8983:8983" --name="k-search-engine" k-search-engine
# now you can connect to http://localhost:8983/solr to browse the SOLR search engine UI
```

where `{version-tag}` is the [version](#versions) of the k-search-engine you want to use

**Caveats**

- The index name on the search engine is `k-search` and cannot be customized.
- the search engine starts in foreground mode, so all log entries are sent to Docker

### Commands

The docker image startup support various commands:

- `start` (default) starts a SOLR instance with the `k-search` index on the default 8983 port
- `optimize` perform optimization maintenance task, see [Optimization section](#optimization)
- `help` output the list of available commands

### Search index storage

The search engine index is stored in `/opt/solr/k-search/k-search/data`, you can mount any volume 
on that folder in order to persist its content.

```
docker run -it --rm -p "8983:8983" --name="k-search-engine" -v "./local-folder:/opt/solr/k-search/k-search/data" k-search-engine
```

## Building

To build the image execute the `docker build` command.

```
# Build the image
docker build -t k-search-engine .
```

## Versions

Version `0.1.0` is the latest compatible with K-Search API version `2.6`. For K-Search API version `3.0` use version `0.2.0` or above.

## Maintenance operations

### Optimization

Sometimes the Search Engine index needs to be optimized. Index optimization is required after 
search engine upgrades (before adding new documents).

To execute the index optimization run

```
# operates on a running instance
docker exec {container-name} /opt/solr/start.sh optimize
```

where `{container-name}` is the name of the container assigned to the search engine.

The command will output something like

```
K-Search Engine, based on SOLR 5.5.4.
Optimizing the index...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   148    0   148    0     0    707      0 --:--:-- --:--:-- --:--:--   711
```
```xml
<?xml version="1.0" encoding="UTF-8"?>
<response>
<lst name="responseHeader"><int name="status">0</int><int name="QTime">52</int></lst>
</response>
```

While in the log you should see an entry with `Starting optimize...`

```
[...] o.a.s.u.DirectUpdateHandler2 Starting optimize... Reading and rewriting the entire index! Use with care.
[...] o.a.s.u.DirectUpdateHandler2 No uncommitted changes. Skipping IW.commit.
[...] o.a.s.c.SolrCore SolrIndexSearcher has not changed - not re-opening: org.apache.solr.search.SolrIndexSearcher
[...] o.a.s.u.DirectUpdateHandler2 end_commit_flush
[...] o.a.s.u.p.LogUpdateProcessorFactory [k-search]  webapp=/solr pa
```

## License

This project is licensed under the AGPL v3 license, see [LICENSE.txt](./LICENSE.txt).
