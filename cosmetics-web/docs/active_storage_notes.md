# ActiveStorage notes

> This should be reviewed on each Rails upgrade

This app uses ActiveStorage for attachments. By default, ActiveStorage uses non-protected urls.
Due to the confidentiality of the data in this app, some ActiveStorage controllers have been re-implemented.

Routes available from ActiveStorage:

```
/rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                                 active_storage/blobs/redirect#show
/rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                    active_storage/blobs/proxy#show
/rails/active_storage/blobs/:signed_id/*filename(.:format)                                          active_storage/blobs/redirect#show
/rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations/redirect#show
/rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)      active_storage/representations/proxy#show
/rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)            active_storage/representations/redirect#show
/rails/active_storage/disk/:encoded_key/*filename(.:format)                                         active_storage/disk#show
/rails/active_storage/disk/:encoded_token(.:format)                                                 active_storage/disk#update
/rails/active_storage/direct_uploads(.:format)                                                      active_storage/direct_uploads#create
```

Routes used by this app:

```
/rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                    active_storage/blobs/proxy#show
/rails/active_storage/disk/:encoded_key/*filename(.:format)                                         active_storage/disk#show
/rails/active_storage/disk/:encoded_token(.:format)                                                 active_storage/disk#update
/rails/active_storage/direct_uploads(.:format)                                                      active_storage/direct_uploads#create
/rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)      active_storage/representations/proxy#show
```

(`active_storage/blobs/proxy#show` has added protection - only owners and search users can access files.)

Routes disabled in this app:

```
/rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                                 active_storage/blobs/redirect#show
/rails/active_storage/blobs/:signed_id/*filename(.:format)                                          active_storage/blobs/redirect#show
/rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations/redirect#show
/rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)            active_storage/representations/redirect#show
```
