var express = require('express');
var path = require('path');

var app = express();

var sqlite3 = require('sqlite3').verbose();

app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/speedtest', function (req, res) {

	var db = new sqlite3.Database('speedtest.sqlite');
	db.serialize(function() {
		db.all("SELECT id, strftime('%s', datetime(timestamp, 'localtime')) as time, host_distance, response_time, download_speed, upload_speed FROM speedtest ORDER BY timestamp ASC LIMIT 1000", function(err, rows) {
		    res.send(rows);
		});
		db.close();
	});
});

app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});