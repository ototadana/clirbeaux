<level>
  <div class="row" if={opts.ctx.email && !level}>
    <spinner></spinner>
  </div>
  <div  class="row" if={level}>
    <h3 class="right-align">Level: <b>{level.level}</b></h3>
    <div class="progress">
      <div class="determinate" style="{'width: ' + (level.progress * 100) + '%' }"></div>
    </div>
    <h5 class="right-align">Exp: {level.exp}</h5>
  </div>
  <style>
    :scope {
      color: #888;
    }

    h3 b {
      font-size: 2em;
      color: black;
    }

    h5 {
      padding-top: 0px;
      margin-top: 0px;
      font-size: 1em;
    }
  </style>

  opts.ctx.on('user-updated', async () => {
    this.level = await opts.ctx.get(
      '/git/level?email=' + encodeURIComponent(opts.ctx.email));

    const data = await opts.ctx.loadPlayerData('git.Level');

    if(data.level && data.level != this.level.level) {
      opts.ctx.showSpecialMessage('Level Up!');
    }

    riot.update();

    await opts.ctx.savePlayerData('git.Level', this.level);
  });
</level>
