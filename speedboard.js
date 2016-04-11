$(function () {
    var downloadSpeed = new Array;
    var uploadSpeed = new Array;
    var responseTime = new Array;
    setTimeout(function() {
        $.getJSON('/api/speedtest', function(data) {
            data.forEach(function(item) {
                timestamp = item.timestamp*1000;
                downloadSpeed.push(new Array(timestamp, item.download_speed));
                uploadSpeed.push(new Array(timestamp, item.upload_speed));
                responseTime.push(item.response_time);
            });

            $('#container').highcharts({
                chart: {
                    zoomType: 'x'
                },
                title: {
                    text: 'Lafourchette Nantes Office internet performance'
                },
                subtitle: {
                    text: document.ontouchstart === undefined ?
                            'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'
                },
                xAxis: {
                    type: 'datetime'
                },
                yAxis: {
                    title: {
                        text: 'Mo/s'
                    }
                },
                legend: {
                    enabled: false
                },
                plotOptions: {
                    area: {
                        fillColor: {
                            linearGradient: {
                                x1: 0,
                                y1: 0,
                                x2: 0,
                                y2: 1
                            },
                            stops: [
                                [0, Highcharts.getOptions().colors[0]],
                                [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                            ]
                        },
                        marker: {
                            radius: 2
                        },
                        lineWidth: 1,
                        states: {
                            hover: {
                                lineWidth: 1
                            }
                        },
                        threshold: null
                    }
                },
                series: [{
                    name: 'Download speed (Mo/s)',
                    data: downloadSpeed
                },{
                    name: 'Upload speed (Mo/s)',
                    data: uploadSpeed
                }]
            });
        });
    }, 5000);
});