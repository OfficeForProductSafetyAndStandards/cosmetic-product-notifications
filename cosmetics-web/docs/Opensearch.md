# Opensearch

Opensearch contains an index for all the completed notifications in the service.
This information is used to enable Notification searches in the service.

The custom logic wraping [ElasticSearch gem](https://github.com/elastic/elasticsearch-rails) used to operate with the indices
is contained in the ["Searchable" model concern](https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications/blob/master/cosmetics-web/app/models/concerns/searchable.rb).

### How do we add/remove notifiations from Opensearch
* When a notification gets completed, it is individually added to the index.
* When a notification is either soft/hard deleted, it is individually removed from the index.

### Regular re-indexing

To resolve any possible inconsistencies between the index information and the information stored in the service database,
there is an scheduled job that will periodically re-index all the published notifications in the service.

The re-index job:
* Creates a new index
* Populates the new index
* If there are any errors during the importing process into the new index:
  * Keeps the previous index.
  * Deletes the new index.
* If the import process succeeds:
  * Hot-swaps the index used by the service by replacing the index pointed at by the model alias.
  * Deletes the previous index.

This approach resolves:
* The index containing deleted notifications that would never be removed if soft/importing (updating without creating an index from scratch).
* Having an empty/incomplete index and missing results on the service during the re-index process.
  As the index grows the re-indexing will take longer. If we inmediately delete and re-create the index from scratch, and the
  service is pointing to that index, this will cause missing results for users that search on the service while the re-index
  is taking process.

### Cleaning unused indices

Sometimes, the job is killed/the service restarted while a re-index job is taking process. This leaves an index in Opensearch
that is empty or partially populated, and that is not pointed at by the model alias.
The model alias will still point to the previous successfully populated index, and will remove this one and point to a new
one when re-indexing next time. Unfortunally, the dangling unused index will still exist in Opensearch.

To avoid having dangling indexes in Opensearch, we implemented another scheduled job that will identify unused indices not
marked as the current one and delete them.

**Do not to schedule this deleting job and the re-index so they run in parallel, as the cleaning job would identify the
new index where the notifications are being imported to as "unused" (before current index alias points to it) and delete it.**

### Using OpenSearch aliases

The `Searchable` models will rely on their `index_name` as OpenSearch alias.
The alias will point to a particular version of the index with this format: `alias_name_timestamp`.
A model with an `index_name dummy_index` declaration, will have an Opensearch alias called `dummy_index`, and `dummy_index`
will point to an index named like: `dummy_index_20221210010115`.

Swaping the particular index that the alias points to allows our service to hot-swap the index in use without need for
re-writing the index name in the code and releasing the changes or restarting the service.

To be able to quickly consult what is the current index used by the model alias, we have implemented `Searchable.current_index` method.
We also have other methods declared in ["Searchable" model concern](https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications/blob/master/cosmetics-web/app/models/concerns/searchable.rb) to manage the indexing/aliasing.

