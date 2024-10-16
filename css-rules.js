'use strict'

// TODO: These rules override those specified in stylelint-config-gds
// (https://github.com/alphagov/stylelint-config-gds)
//
// This has been done temporarily in order to introduce stylelint-config-gds,
// but should be removed when possible.
module.exports = {
  rules: {
    'declaration-no-important': null,
    'selector-max-id': null,
    'selector-no-qualifying-type': null,
    'max-nesting-depth': 6
  }
}
