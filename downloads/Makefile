all: langdetect-03-03-2014.zip solr-4.10.4.zip

langdetect-03-03-2014.zip:
	wget http://language-detection.googlecode.com/git-history/packages/packages/langdetect-03-03-2014.zip
	md5sum -c langdetect-03-03-2014.zip.md5
solr-4.10.4.zip:
	wget http://mirror1.mirror.garr.it/mirrors/Apache/lucene/solr/4.10.4/solr-4.10.4.zip
	md5sum -c solr-4.10.4.zip.md5
.PHONY: check
check:
	md5sum -c langdetect-03-03-2014.zip.md5
	md5sum -c solr-4.10.4.zip.md5
