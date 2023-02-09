# Frame formulations

Frame formulations are predefined groups of ingredients that are commonly used in many cosmetic preparations.
They are mainly used in two places in the "submit" app:

* During the product notification journey, where they are offered to the user in a dropdown list format which is
  filtered based on their selection of category/sub-category/sub-sub-category for the product they are notifying.
  The user can select the frame formulation that matches the product's recipe as an alternative to manually
  entering each ingredient and its quantity.
* On the "find a frame formulation" page, where they are grouped by high-level categories and presented together
  with their ingredients and quantities.

The source for all frame formulation data are the JSON files in `app/assets/files/frame_formulations`:

* Files prefixed with a number contain frame formulation data
* `categories.json` contains the category hierarchy that matches the category/sub-category/sub-sub-category that
  users select when notifying a product, along with a list of frame formulations that are applicable to the given
  category selection. This allows the dropdown list to be filtered to only show applicable frame formulations.
* `other.json` contains a simpler list of "other" entries. These entries are provided for each sub-sub-category
  and are not themselves frame formulations, but rather an option the user can select from the dropdown list if
  none of the provided frame formulations match their product's recipe.
* `view_only.json` contains a simpler list of frame formulations that can no longer be selected when notifying a
  new product. This list allows products previously notified products with these frame formulations to be displayed
  correctly. An entry is made in this file if the frame formulation doesn't exist in the numbered files for any
  reason.

These JSON files are consumed by the `FrameFormulations` class in `app/models/frame_formulations.rb`. This class
then exposes both the raw data and various combinations as Ruby-native data structures to be consumed elsewhere in
the app.

# Adding a frame formulation

To add a frame formulation:

* Add the frame formulation to one of the existing numbered JSON files, ensuring all fields are completed. If none
  of the existing files is a good fit category-wise, create a new file, and ensure this file is consumed by the
  `FrameFormulations` class. Note, the formulation ID is internal to the app and is derived simply from the name.
* Add the formulation ID under the appropriate categories in `categories.json` so that it appears in the dropdown
  list when any of those categories are chosen.

# Editing a frame formulation

Any details for a frame formulation may be edited in the appropriate JSON file. However, do not change the formulation
ID, otherwise existing notifications will contain invalid frame formulations.

# Deleting a frame formulation

> **WARNING:** This is probably not what you want to do, since it will have consequences if any search user attempts to
> view the ingredients for a deleted frame formulation. Please ensure this is the correct course of action.

To delete a frame formulation:

* Remove the frame formulation from the existing numbered JSON file where it is defined.
* Add the formulation ID for the removed frame formulation to `view_only.json` along with its name so that existing
  notification continue to display correctly.

# Ensuring the category hierarchy and definitions match

For frame formulations to display correctly:

* It must either be defined in one of the numbered JSON files **or** be contained in `other.json` if it is an "other"
  entry.
* It must be defined at least once somewhere in the category hierarchy in `categories.json` (it can be defined under
  more than one category).

To ensure that all frame formulations meet the above requirements, run `bundle exec rake frame_formulations:diff`.
This Rake task will output the number of frame formulations in each place and a list of frame formulations that are
missing from either place.

To include frame formulations defined in `view_only.json` (which would otherwise be reported as missing), run
`bundle exec rake frame_formulations:diff[true]`. For the `zsh` shell, escape square brackets with backslashes.
