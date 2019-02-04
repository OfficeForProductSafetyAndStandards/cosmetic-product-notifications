const { environment } = require('@rails/webpacker');

environment.loaders.get('sass').use.splice(-1, 0, {
    loader: 'resolve-url-loader'
});

environment.loaders.append('json', {
    type: 'javascript/auto',
    test: /\.json$/,
    use: [ { loader: 'file-loader' } ]
});

module.exports = environment;
