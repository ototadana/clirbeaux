<badges>
  <div class="row">
    <div if={opts.ctx.email && !contributes}>
      <spinner></spinner>
    </div>
    <div if={contributes}>
      <h5>Projects</h5>
      <ul>
        <li each={contributes}>
          <badge key={key} count={value} all={all} highlight={highlight} onclick={showContributers}></badge>
        </li>
      </ul>
    </div>
  </div>
  <div class="row">
    <div if={opts.ctx.email && !skills}>
      <spinner></spinner>
    </div>
    <div if={skills}>
      <h5>Languages</h5>
      <ul>
        <li each={skills}>
          <badge key={key} count={value} all={all} highlight={highlight} onclick={showLanguageMasters}></badge>
        </li>
      </ul>
    </div>
  </div>
  <style>
    li {
      display: inline;
    }
    badge {
      cursor: pointer
    }
  </style>

  opts.ctx.on('user-updated', () => {
    this.getContributes();
    this.getSkills();
  });

  async getContributes() {
    if(opts.ctx.email) {
      this.contributes = await opts.ctx.get(
        '/git/contributes?email=' + encodeURIComponent(opts.ctx.email));
      await this.updatePlayerData('Projects', this.contributes);
    } else {
      this.contributes = undefined;
      this.update();
    }
  };

  async getSkills() {
    if(opts.ctx.email) {
      this.skills = await opts.ctx.get(
        '/git/skills?email=' + encodeURIComponent(opts.ctx.email));
      await this.updatePlayerData('Languages', this.skills);
    } else {
      this.skills = undefined;
      this.update();
    }

  };

  async updatePlayerData(type, badges) {
    let updated = false;
    const data = await opts.ctx.loadPlayerData('git.' + type);

    for(let i = 0; i < badges.length; i++) {
      const badge = badges[i];
      const value = data[badge.key];
      if(value && value != badge.value) {
        updated = true;
        badge.highlight = 'highlight';
      }
      data[badge.key] = badge.value;
    }
    if(updated) {
      opts.ctx.showMessage(type + ' updated');
    }

    this.update();

    await opts.ctx.savePlayerData('git.' + type, data);
  };

  async showContributers(e) {
    const ranking = await opts.ctx.get(
      '/git/contributers?project=' + encodeURIComponent(e.item.key));
    opts.ctx.showRanking(ranking, {header: e.item.key, showbadge: true});
  }

  async showLanguageMasters(e) {
    const ranking = await opts.ctx.get(
      '/git/language-masters?language=' + encodeURIComponent(e.item.key));
    opts.ctx.showRanking(ranking, {header: e.item.key, showbadge: true});
  }
</badges>
