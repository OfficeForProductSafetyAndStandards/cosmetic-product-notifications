const express = require('express');
const sassMiddleware = require('node-sass-middleware');
const nunjucks = require('nunjucks');
const path = require('path');
const app = express();

// Sass configuration
app.use(sassMiddleware({
    src: path.join(__dirname, 'src/assets/scss'),
    dest: path.join(__dirname, 'public'),
    debug: true,
    outputStyle: 'compressed',
    prefix: '/public'
}));
app.use('/public', express.static(path.join(__dirname, 'public')));

// Javascript configuration
app.use('/public/all.js', express.static(path.join(__dirname, 'node_modules/govuk-frontend/all.js')))
app.use('/public/html5shiv.js', express.static(path.join(__dirname, 'node_modules/html5shiv/dist/html5shiv.js')))

// Nunjucks configuration
nunjucks.configure([path.join(__dirname, 'src/views'), path.join(__dirname, 'node_modules/govuk-frontend'), path.join(__dirname, 'node_modules/govuk-frontend/components')], {
    autoescape: true,
    express: app
});
app.set('view engine', 'html');

// GOV.UK Design System assets configuration
app.use('/assets', express.static(path.join(__dirname, 'node_modules/govuk-frontend/assets')))

app.get('*', (_req, res) => {
    res.status(503);
    res.set('Retry-After', '3600');
    res.render('index');
});

app.listen(process.env.PORT || 3005);
