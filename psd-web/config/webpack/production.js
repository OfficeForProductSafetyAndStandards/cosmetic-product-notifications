process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('../../vendor/shared-web/config/webpack/environment');

module.exports = environment.toWebpackConfig();
