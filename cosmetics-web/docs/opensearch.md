# OpenSearch

OpenSearch contains an index for all the completed and archived notifications in the service. This powers
notification searching for both the search and submit services.

The ["Searchable" model concern](https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications/blob/main/cosmetics-web/app/models/concerns/searchable.rb)
wraps the [ElasticSearch gem](https://github.com/elastic/elasticsearch-rails).

## Adding/updating/removing notifications

* When a notification is completed, it is added to the index.
* When a notification is archived or unarchived, its status is updated in the index.
* When a notification is either soft/hard deleted, it is removed from the index.

## Regular re-indexing

To resolve any possible inconsistencies between the index data and the information stored in the app database,
there is an scheduled background job (`ReindexOpensearchJob`) that periodically re-indexes all the completed
and archived notifications in the service.

The re-indexing job:

* Creates a new index
* Populates the new index
* If there are any errors during the importing process into the new index:
  * Keeps the previous index
  * Deletes the new index
* If the import process succeeds:
  * Hot-swaps the index used by the service by replacing the index pointed at by the model alias
  * Deletes the previous index

This approach resolves:

* The index containing deleted notifications that would never be removed if soft/importing
  (updating without creating an index from scratch).
* Having an empty/incomplete index and missing results on the service during the re-index process.
  As the index grows the re-indexing will take longer. If we immediately delete and re-create the index
  from scratch, and the service is pointing to that index, this will cause missing results for users
  that search on the service while the re-index is taking process.

## Cleaning unused indices

Sometimes, the re-indexing job is killed or the app is restarted while a re-indexing job is taking process.
This leaves an index in OpenSearch that is empty or partially populated, and that is not pointed at by the
model alias.

The model alias will still point to the previous successfully populated index, and will remove this one
and point to a new one when re-indexing next time. Unfortunately, the dangling unused index will still
exist in OpenSearch.

To avoid having dangling indexes in OpenSearch, a scheduled background job (`DeleteUnusedOpensearchIndicesJob`)
identifies unused indices not marked as the current one and deletes them.

**Do not to schedule this deleting job and the re-index so they run in parallel, as the cleaning job
would identify the new index where the notifications are being imported to as "unused" (before current
index alias points to it) and delete it.**

## Using OpenSearch aliases

To allow index hot-swapping without downtime, aliases are used to point to the current index.

Any model that uses the `Searchable` concern implements an `index_name` model that defines the alias name.
The alias will point to a particular version of the index with this format: `alias_name_timestamp`.
A model with an `index_name dummy_index` declaration, will have an OpenSearch alias called `dummy_index`,
and `dummy_index` will point to an index named `dummy_index_20221210010115`.

The `Searchable.current_index` method always points to the full name of the current index.
