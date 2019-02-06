const { environment } = require('@rails/webpacker');

// We want to use a different postcss config for ie8 https://github.com/rails/webpacker/issues/1220
delete environment.loaders.get('css').use.find(loader => loader.loader === 'postcss-loader').options.config;
delete environment.loaders.get('sass').use.find(loader => loader.loader === 'postcss-loader').options.config;

// Copy JSON files to the output, rather than reading them as JS
environment.loaders.append('json', {
  type: 'javascript/auto',
  test: /\.json$/,
  use: [{ loader: 'file-loader' }],
});

module.exports = environment;
