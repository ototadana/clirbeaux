<velocity>
  <div class="row">
    <div if={opts.ctx.email && !chart}>
      <spinner></spinner>
    </div>
    <div show={chart}>
      <h4>Codes</h4>
      <canvas id="myChart" width="100" height="40"></canvas>
    </div>
  </div>

  this.on('mount', () => {
    var ctx = document.getElementById("myChart").getContext('2d');
    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [{
          label: '# of Lines',
          borderWidth: 1
        }]
      },
      options: {
        onClick: async (e) => {
          var chart = this.chart;
          var point = chart.getElementAtEvent(e)[0];
          var month;
          if(point) {
            month = chart.data.labels[point._index];
          } else {
            month = 'ALL';
          }

          const ranking = await opts.ctx.get(
            '/git/player-ranking-of-month?month=' + encodeURIComponent(month));
          opts.ctx.showRanking(ranking, {header: month, showbadge: false});
        },
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero:true
            }
          }]
        }
      },
    });
  });

  opts.ctx.on('user-updated', async () => {
    const monthlyLines = await opts.ctx.get(
      '/git/monthly-lines?email=' + encodeURIComponent(opts.ctx.email));

    var labels = [];
    var data = [];
    for(var i = 0; i < monthlyLines.length; i++) {
      labels.push(monthlyLines[i].key);
      data.push(monthlyLines[i].value);
    }

    this.chart.data.datasets[0].data = data;
    this.chart.data.labels = labels;
    this.chart.update();
    riot.update();
  });
</velocity>
