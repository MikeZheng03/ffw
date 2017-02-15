$(function ()  {
		
	    chart = Highcharts.chart('path', {
	        chart: {
	            type: 'line',
				marginTop: 20,
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
				lineWidth: 1
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
						x:5,
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
						allowOverlap: true,
						color: '#7cb5ec',
						style: {
							textOutline: 0,
							fontWeight: 'normal',
							fontSize: '12px'
						},
						overflow: true,
						crop: false
					}
				}
	        },
			series: []
	}
		);
		
	});

//var t=true;
//setInterval("testChangeData()",1000);
function testChangeData() {
 var data1 = {
             showInLegend: false,
             data: [
             {
                 name:"111",
				 color: '#00FF00',
                 x: 1.5,
                 y: 26.5,
                 marker: {
                     symbol: 'url(img/marker.png)'
                 }
             },
			 {
                 name:"aaa",
				 color: '#00FF00',
                 x: 3.5,
                 y: 50,
                 
             }]
         };
         var data2 = {
             showInLegend: false,
             data: [
             {
                 name:"222",
				 color: '#00FF00',
                 x: 1.5,
                 y: 36.5,
                 marker: {
                     symbol: 'url(img/marker.png)'
                 }
             },
			 {
                 name:"bbb",
				 color: '#00FF00',
                 x: 3.5,
                 y: 50,
                 
             }]
         };
	if(chart.series.length == 1)
		chart.series[0].remove(false);

	//
     console.log(chart.series);
     if(t==true){
     chart.addSeries(data1);
	 //chart.series[0].setData(data1);
     t=false;
     }
     else{
     chart.addSeries(data2);
	 //chart.series[0].setData(data2);
     t=true;
     }

	chart.redraw();
}

function changeData(jsonData1, jsonData2){
	//console.log("changeData jsonData:"+jsonData1);
	if(chart.series.length == 0) {
		chart.addSeries(jsonData1);
		chart.addSeries(jsonData2);
		//chart.series[0].data[3].marker.symbol
		//console.log("changeData add jsonData1,symbol:"+chart.series[3].marker.symbol);
	}
	else if(chart.series.length > 1) {
		//console.log("changeData add jsonData2");
		chart.series[1].remove(false);
		chart.addSeries(jsonData2);
	}
	//console.log("changeData chart.series:"+chart.series);
	
	chart.redraw();
	
}
