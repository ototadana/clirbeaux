<treasure-box>
  <div class="row">
    <div if={opts.ctx.email && !treasures}>
      <spinner></spinner>
    </div>
    <div if={treasures && treasures.length > 0}>
      <ul class="collapsible {highlight}">
        <li>
          <div class="collapsible-header">
            <i class="material-icons">cake</i>Treasure Box
          </div>
          <div class="collapsible-body">
            <div class="row" each={treasures}>
              <div class="col m1"><b>#{ref}</b></div>
              <div class="col m11"><a href={taskUrl} target="taiga">{subject}</a> - <a href={usUrl} target="taiga">{us}</a></div>
            </div>
          </div>
        </li>
      </ul>

    </div>
  </div>
  <style>
    .highlight {
      animation: blink .5s step-end 10 alternate;
    }

    ul.collapsible {
      margin-left: 12px;
      box-shadow: none;
      boder: solid 1px #eee;
    }

    @keyframes blink {
      50% {
        opacity: 0.5;
        box-shadow: 0 0 8px gray;
        color: #A88666;
      }
    }

    .collapsible-header {
      color: #555;
    }

    b {
      font-weight: bold;
      color: #A88666;
    }
  </style>

  opts.ctx.on('user-updated', async () => {
    if(!opts.ctx.taiga.user) {
      this.treasures = undefined;
      this.update();
      return;
    }

    this.treasures = await opts.ctx.get(
      '/taiga/treasures?authToken=' + 
        encodeURIComponent(opts.ctx.taiga.user.auth_token) +
        '&uid=' + encodeURIComponent(opts.ctx.taiga.user.id));

    await this.updatePlayerData(this.treasures);
    this.update();
    M.Collapsible.init($('.collapsible'), {});
  });

  async updatePlayerData(tresures) {
    let updated = false;
    const data = await opts.ctx.loadPlayerData('taiga.Tresures');

    for(let i = 0; i < tresures.length; i++) {
      const tresure = tresures[i];
      const value = data[tresure.ref];
      if(!value) {
        updated = true;
      }
      data[tresure.ref] = tresure;
    }

    if(updated) {
      this.highlight = 'highlight';
      opts.ctx.showMessage('Found a Treasure!');
    }

    await opts.ctx.savePlayerData('taiga.Tresures', data);
    this.update();
  };
</treasure-box>
