# Elasticsearch/OpenSearch Circuit Breaker Fixes

## Problem

The application was experiencing circuit breaker exceptions in Elasticsearch/OpenSearch when trying to index large notifications. This was manifesting as:

1. `Elastic::Transport::Transport::Errors::TooManyRequests` errors
2. Circuit breaker exceptions with messages like `[parent] Data too large, data for [<http_request>] would be [1394991036/1.2gb], which is larger than the limit of [1382652313/1.2gb]`
3. Failures during the `ResponsiblePersons::DraftsController#accept` action
4. Timeouts during reindexing jobs

## Solutions Implemented

### 1. Document Size Limitations

- Added a method to check document size before indexing
- Set a maximum document size of 1MB (well below circuit breaker limits)
- Prevented indexing of documents that exceed this limit

### 2. Optimized JSON Payload

- Streamlined the `as_indexed_json` method in the Notification model
- Limited the number of ingredients indexed (max 50 per component, 100 total)
- Reduced the fields included in the indexed document
- Removed unnecessary nested data

### 3. Error Handling and Recovery

- Added error handling around indexing operations
- Ensured notification submission continues even if indexing fails
- Added better logging for OpenSearch-related issues
- Created custom middleware to handle circuit breaker exceptions

### 4. Connection and Timeout Improvements

- Increased request timeouts (30s default, 60s in production)
- Added retry mechanism for failed requests
- Set batch size for bulk operations to 50 documents

### 5. Monitoring and Diagnostics

- Created a new `CheckDocumentSizesJob` to identify problematic documents
- Added a rake task to run the document size check job
- Improved logging throughout the codebase

## Future Considerations

1. **Elasticsearch Cluster Scaling**: When migrating to AWS, consider increasing the OpenSearch cluster resources
   to accommodate larger documents and higher indexing load.

2. **Document Partitioning**: For extremely large notifications, consider partitioning the document or
   implementing a more selective indexing strategy.

3. **Regular Monitoring**: Schedule regular runs of the `check_document_sizes` task to proactively identify problems.

4. **Database Cleanup**: Consider implementing a cleanup process for old or excessively large notifications.

## References

- PSD-5664: Fix Elasticsearch circuit breaker exceptions
- [OpenSearch Documentation - Circuit Breaker](https://opensearch.org/docs/latest/monitoring-plugins/pa/circuit-breaker/)
