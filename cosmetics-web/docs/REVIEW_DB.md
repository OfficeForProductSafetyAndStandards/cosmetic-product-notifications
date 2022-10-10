To dump staging db:

Use dumped db on localhost so you can enhance the data.

On localhost, on stagingg DB, run script:

`rails r db/seeds/enhance_db_with_extra_data.rb`

please note that you need to have `names.csv` file in main directory.
This file should include product name per line. This names can be taken from
production, as production names are not sensible data.

Dump enhanced db on localhost again:

``

And create db on review app:

``
