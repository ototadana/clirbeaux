<velocity>
  <div class="row">
    <div if={opts.ctx.email && !chart}>
      <spinner></spinner>
    </div>
    <div show={opts.ctx.email && chart}>
      <h4>Codes</h4>
      <canvas id="myChart" width="100" height="40"></canvas>
    </div>
  </div>

  this.on('mount', () => {
    const ctx = document.getElementById("myChart").getContext('2d');
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
          const chart = this.chart;
          const point = chart.getElementAtEvent(e)[0];
          let month;
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
    if(!opts.ctx.email) {
      this.update();
      return;
    }

    const monthlyLines = await opts.ctx.get(
      '/git/monthly-lines?email=' + encodeURIComponent(opts.ctx.email));

    const labels = [];
    const data = [];
    for(let i = 0; i < monthlyLines.length; i++) {
      labels.push(monthlyLines[i].key);
      data.push(monthlyLines[i].value);
    }

    this.chart.data.datasets[0].data = data;
    this.chart.data.labels = labels;
    this.chart.update();
    this.update();
  });
</velocity>
