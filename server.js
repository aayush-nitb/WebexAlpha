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
        return '/public/' + this.base + '/' + file
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

var fileRegex = function (molecule, dir, ext, file) {
    var path_array = [];
    var pathsep = '\\' + path.sep;
    if (molecule == 'molecules') {
        path_array.push('molecules' + pathsep + '([^' + pathsep + ']+)');
    }
    else {
        path_array.push(molecule);
    }
    path_array.push(dir);
    if (file) {
        path_array.push(file + '\.' + ext);
    }
    else {
        path_array.push('.+\\.' + ext);
    }
    return "^" + path_array.join(pathsep) + "$";
};

var app = express();
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname);
app.set('view engine', 'jade');
app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')));
app.use('/bower_components', express.static(path.join(__dirname, 'bower_components')));
app.use('/public', express.static(path.join(__dirname, 'public')));

var mainAppearance = fileRegex("main", "appearance", "less");
var moleculeAppearance = fileRegex("molecules", "appearance", "less");
var mainController = fileRegex("main", "controllers", "coffee");
var moleculeController = fileRegex("molecules", "controllers", "coffee");
var mainService = fileRegex("main", "services", "coffee", "index");
var moleculeService = fileRegex("molecules", "services", "coffee", "index");

["main", "molecules"].forEach(function (srcCode) {
    var molecules = walk.walk(srcCode, { followLinks: false });
    molecules.on('file', function (root, stat, next) {
        var filename = path.join(root, stat.name);
        if (filename.match(mainController) || filename.match(moleculeController)) {
            render("js", filename, function (data, outfile) {
                var compiled = coffee.compile(data);
                write(compiled, root, outfile);
            });
        }
        if (filename.match(mainAppearance) || filename.match(moleculeAppearance)) {
            render("css", filename, function (data, outfile) {
                less.render(data).then(function (compiled) {
                    write(compiled.css, root, outfile);
                });
            });
        }
        if (filename.match(mainService)) {
            app.use("/", require("./main/services/index"));
        }
        if (filename.match(moleculeService)) {
            var service_path = new RegExp(moleculeService);
            var match = service_path.exec(filename);
            app.use("/molecules/" + match[1], require("./molecules/" + match[1] + "/services/index"));
        }
        next();
    });
});

routes.configure(app, fileProvider);

app.listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});