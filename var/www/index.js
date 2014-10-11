var express = require('express');

var app = express();
app.route('*').all(function(req, res, next) {
    res.send('Hello World!');
});
app.listen(2000);