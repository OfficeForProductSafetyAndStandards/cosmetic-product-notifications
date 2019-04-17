# Shared Web

This folder contains a [Rails engine](https://guides.rubyonrails.org/engines.html) containing common code for OPSS web applications.

Features of this engine include:
- The [GOV.UK Design System](https://design-system.service.gov.uk/)
- Support for [GOV.UK Notify](https://www.notifications.service.gov.uk/)
- Various linting tools (e.g. rubocop, slim-lint)

# Installation

Add the following to your project's Gemfile:

```ruby
gem 'shared-web', path: '<path to shared web>'
```
and run `bundle install`

To add the shared NPM packages, run
```bash
yarn add <path to shared web>
```

# Design System Components
The [GOV.UK design system](https://design-system.service.gov.uk) provides a reference implementation of its components
in nunjucks, which are unfortunately not supported on ruby. In lieu of that, we are implementing 
slim versions of the components that can be used throughout the applications.
In the future, this could be split off as its own gem.

## Component implementations
Component implementations can be found in the [components directory](app/views/components). They try to follow the 
nunjucks implementations as close as possible. In particular, we are keeping the interface the same (param names etc.) 
to make translating code between the macros usage and our implementation as close as possible.
This means that we can use the documentation provided by design system for macro options,
e.g. see [macro options for radios](https://design-system.service.gov.uk/components/radios/#options-example-default) 

Notable differences from nunjucks:
- we are not allowing unescaped html in `html` attributes. Instead, the expected use-case is to build the required html
     in slim and `capture` it, e.g.:
    ```slim
    - html = capture do
      h3 Custom html content
    = render "components/govuk_label", html: html, for: "someId"
    ```
    This renders most `text` and `html` attributes functionally identical, but we are choosing to keep both for consistency
    with nunjucks templates
- We extended govuk_select component to streamline using it as accessible autocomplete component.
    Our version accepts extra options:
    - is_autocomplete, when true, makes the select an
    [accessible autocomplete](https://github.com/alphagov/accessible-autocomplete)
    - show_all_values, when true and is_autocomplete true, makes the autocomplete show all values,
    as well as adds an 'x' to remove currently selected value.
- hidden fields in checkboxes, to account for rails checkboxes "gotcha". The default value is 0 but can be set through the 'unchecked_value' attribute.
  https://apidock.com/rails/ActionView/Helpers/FormHelper/check_box

## Rails integration
To simplify working with rails form helpers, we are also providing a bit of "glue" which infers the values that it
can from the form object and converts them into appropriate params for the view components. Those can be found
in the [form_components directory](app/views/form_components).
The intent of keeping this "glue" separate from the component implementations is to make keeping the components up to
date with the corresponding macros as simple as possible.

## Gallery
As a way to showcase the possible use cases, we are providing "gallery" pages. They are based on examples provided
in the govuk-frontend repo, e.g. [radios examples]( 
https://github.com/alphagov/govuk-frontend/blob/943ff14752f0a8a765ee3f90bc3e1ecd9205e36c/src/components/radios/radios.yaml).

The gallery pages area available at `/components/<component_name>`, and only get mounted in dev mode.

