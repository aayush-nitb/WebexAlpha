require('wiredep')({
    src: 'views/layout.jade',
    ignorePath: '../'
});

var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , fs = require('fs')
  , walk = require('walk')
  , coffee = require('coffee-script')
  , path = require('path');

var controllers = walk.walk('./controllers', { followLinks: false });
controllers.on('file', function (root, stat, next) {
    var filename = path.join(root, stat.name);
    var outfile = path.join("public/javascripts", stat.name + ".js");
    fs.readFile(filename, 'utf8', function (err, data) {
        var compiled = coffee.compile(data);
        fs.writeFile(outfile, compiled, function(err){
            if(!err) console.log("Compiled: " + filename + ", Output: " + outfile);
        });
    });
    next();
});

var app = express();

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use('/bower_components', express.static(path.join(__dirname, 'bower_components')));
  app.use('/public', express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', routes.index);
app.get('/users', user.list);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
