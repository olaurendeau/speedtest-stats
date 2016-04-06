$(function () {
    console.log('coucou');

    var timestamp = new Array;
    var downloadSpeed = new Array;
    var uploadSpeed = new Array;
    var responseTime = new Array;
    $.getJSON('http://localhost:1515/api/speedtest', function(data) {
		data.forEach(function(item) {
            timestamp.push(item.timestamp);
            downloadSpeed.push(item.download_speed);
            uploadSpeed.push(item.upload_speed);
            responseTime.push(item.response_time);
            console.log(item);
        });

        $('#container').highcharts({
            title: {
                text: 'Monthly Average Temperature',
                x: -20 //center
            },
            subtitle: {
                text: 'Source: WorldClimate.com',
                x: -20
            },
            xAxis: {
                categories: timestamp
            },
            yAxis: {
                title: {
                    text: 'Mo/s'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            tooltip: {
                valueSuffix: 'Mo/s'
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle',
                borderWidth: 0
            },
            series: [{
                name: 'Download speed (Mo/s)',
                data: downloadSpeed
            },{
                name: 'Upload speed (Mo/s)',
                data: uploadSpeed
            },{
                name: 'Response time (ms)',
                data: responseTime
            }]
        });
    });
});