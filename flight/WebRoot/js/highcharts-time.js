$(function ()  {
		
	    chart_time = Highcharts.chart('timeBoard', {
	        chart: {
	            type: 'line',
				//marginLeft: 100,
				marginBottom: 50,
	            backgroundColor: 'rgba(50,50,50,1)'
	        },
			credits: {  
	            enabled: false // remove high chart logo hyper-link  
	        },
	        exporting: {
            	enabled: false
			},
	        title: {
	            text:null
	        },
	        subtitle: {
	            text:null
	        },
	        xAxis: {
				labels: {
	                enabled: false
	            },
				tickWidth: 0,
				lineWidth: 0,
				max:1.1,
				min:0
	        },
	        yAxis: {
	            title: {
	                text: null
	            },
				labels: {
	                enabled: false
	            },
				gridLineWidth: 0
	        },
	        plotOptions: {
	            line: {
	                dataLabels: {
	                    enabled: true,
						
						allowOverlap: true,
						formatter: function() { 
							return  this.point.name;
						}
	                },
	                enableMouseTracking: false
					
	            },
				series: {
					animation: false,
					color: '#7cb5ec',
					marker: {
						enabled: true,
						radius: 3,
						symbol: 'circle'
					},
					dataLabels: {
						enabled: true,
						y:15,
						x:-5,
						//allowOverlap: true,
						color: '#7cb5ec',
						align: 'right',
						style: {
							textOutline: 0,
							fontWeight: 'normal',
							fontSize: '12px'
						}
					}
				}
	        },
        series: []
	}
		);
		
	});


function changeTimeData(jsonData1, jsonData2){
	//console.log("changeData jsonData:"+jsonData1);
	if(chart_time.series.length == 0) {
		chart_time.addSeries(jsonData1);
		chart_time.addSeries(jsonData2);
		//console.log("changeTimeData add jsonData1");
	}
	if(chart_time.series.length > 1) {
		//console.log("changeTimeData add jsonData2");
		chart_time.series[1].remove(false);
		chart_time.addSeries(jsonData2);
	}
	//console.log("changeTimeData chart.series:"+chart_time.series);
	
	//chart.redraw();
	
}
