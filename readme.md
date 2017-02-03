# SolrCloud Docker image
 

## Upgrade paths
 When switching to a higher Solr version, some operations need to be performed after
 the switch to the new framework.
 In particular:
 
 1. Only one major version upgrade a time, thus Aolr4 to Solr5, or Solr5 to Solr6.
 2. Backup the `data/` folder (just in case) after the container has been shutdown between upgrades
 3. Keep the `data/` folder as it is between upgrades
 4. Optimize each index after the upgrade, so the internal structure will use the new
    storing system of the newest Solr framework.
    The optimization can be run both from a `curl` call, or from a KCore command (see below)
 
### Automated upgrade

The Automated upgrade is performed by Docker when the startup command is the followting:
 `start-optimize-stop-start-foreground` (by default).
 
Docker will start Solr and perform the following operations:
 1. Start Solr in background mode
 2. Invoke `curl` to optimize the index
 3. Stop Solr
 4. Start solr in foreground mode (as normal)

### Manual upgrade
The Manual upgrade must be performed by the following:
  1. Stop the current Solr container
  2. Upgrade the Solr container
  3. Start the new Solr container bu using the command `start-foreground`
  4. Perform one of the "Solr optimization" described below

## Solr optimization

### KCore command
The KCore provides a helpful command to handle the index optimization, after the container
is properly working (and connected to the local/public cores):

Run `app/console kcore:optimize` to optimize all the available cores.

If just one index should be optimized, run one of the following commands:
 - Run `app/console kcore:optimize --core=public` to optimize the "public" core.
 - Run `app/console kcore:optimize --core=private` to optimize the "private" core.


### CUrl invocation

Use `curl` command to perform the index optimization, to run inside the container:

  - Optimize the public core index:
    `curl http://localhost:8983/solr/klink-public/update?optimize=true&maxSegments=1&waitFlush=false`

  - Optimize the private core index:
    `curl http://localhost:8984/solr/klink-private/update?optimize=true&maxSegments=1&waitFlush=false`
