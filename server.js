require('coffee-script/register');

require('wiredep')({
    src: 'main/views/layout.jade',
    ignorePath: '../..'
});

var express = require('express')
    , routes = require('./routes')
    , http = require('http')
    , fs = require('fs')
    , walk = require('walk')
    , mkdirp = require("mkdirp")
    , coffee = require('coffee-script')
    , less = require('less')
    , path = require('path');

var fileProvider = function(file){
    if(file.match("^/?appearance/")){
        return '/public/'+ this.base + '/' + file + '.css'
    }
    if(file.match("^/?controllers/")){
        return '/public/'+ this.base + '/' + file + '.js'
    }
    if(file.match("^/?images/")){
        return '/' + this.base + '/' + file
    }
};
var render = function(type, filename, renderer){
    var outfile = path.join("public", filename + "." + type);
    fs.readFile(filename, 'utf8', function (err, data) {
        renderer(data, outfile);
    });
};
var write = function(compiled, root, outfile){
    root = path.join("public", root);
    mkdirp(root, function (err) {
        if(!err){
            fs.writeFile(outfile, compiled, function (err) {
                if (!err) console.log("RENDERED " + outfile);
                else console.log(err);
            });
        }
    });
};

["main", "molecules"].forEach(function(srcCode){
    var molecules = walk.walk(srcCode, {followLinks: false});
    molecules.on('file', function (root, stat, next) {
        var filename = path.join(root, stat.name);
        if (stat.name.match("\.coffee$")) {
            render("js", filename, function(data, outfile){
                var compiled = coffee.compile(data);
                write(compiled, root, outfile);
            });
        }
        if (stat.name.match("\.less$")) {
            render("css", filename, function(data, outfile){
                less.render(data).then(function (compiled) {
                    write(compiled.css, root, outfile);
                });
            });
        }
        next();
    });
});

var app = express();
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname);
app.set('view engine', 'jade');
app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')));
app.use('/bower_components', express.static(path.join(__dirname, 'bower_components')));
app.use('/public', express.static(path.join(__dirname, 'public')));

routes.configure(app, fileProvider);
app.listen(3000);