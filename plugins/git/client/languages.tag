<languages>
  <div class="row">
    <div if={opts.ctx.email && !languages}>
      <spinner></spinner>
    </div>
    <div show={languages}>
      <canvas id="langChart" width="100" height="150"></canvas>
    </div>
  </div>
  <style>
    canvas {
      opacity: 0.9;
    }
  </style>

  this.on('mount', () => {
    const ctx = document.getElementById("langChart").getContext('2d');

    this.langChart = new Chart(ctx, {
      type: 'pie',
      data: {
        datasets: [{
          data: [],
          backgroundColor: []
        }]
      },
      options: {
        legend: {
          position: 'bottom'
        },
        onClick: async (e) => {
          const chart = this.langChart;
          const point = chart.getElementAtEvent(e)[0];
          if(point) {
            const lang = chart.data.labels[point._index];

            const ranking = await opts.ctx.get(
              '/git/language-masters?language=' + encodeURIComponent(lang));
            opts.ctx.showRanking(ranking, {header: lang, showbadge: true});
          }
        }
      }
    });
  });

  opts.ctx.on('user-updated', async () => {
    if(!opts.ctx.email) {
      this.languages = undefined;
      this.update();
      return;
    }

    this.languages = await opts.ctx.get(
      '/git/skills?email=' + encodeURIComponent(opts.ctx.email));

    const sorted = this.languages.sort((a,b) => {return b.value - a.value;});
    const labels = [];
    const data = [];
    const color = [];
    for(let i = 0; i < sorted.length; i++) {
      labels.push(sorted[i].key);
      data.push(sorted[i].value);
      color.push(this.intToRGB(this.hashCode(sorted[i].key)));
    }

    this.langChart.data.datasets[0].data = data;
    this.langChart.data.datasets[0].backgroundColor = color;
    this.langChart.data.labels = labels;
    this.langChart.update();
    this.update();
  });

  hashCode(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    return hash;
  }

  intToRGB(i) {
    const c = (i & 0x00FFFFFF).toString(16).toUpperCase();
    return "#00000".substring(0, 7 - c.length) + c;
  }

</languages>
