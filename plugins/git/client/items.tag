<items>
  <div class="row">
    <div if={opts.ctx.email && !items}>
      <spinner></spinner>
    </div>
    <div if={items}>
      <h5><i class="material-icons">vpn_key</i>Items</h5>
      <ul class="collapsible">
        <li each={this.items}>
          <div class="collapsible-header">{type}</div>
          <div class="collapsible-body">
            <div each={items}>
              <item  key={key} count={value} projects={projects} onclick={showItemHolders}></item>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
  <style>
    item {
      cursor: pointer
    }
  </style>

  opts.ctx.on('user-updated', async () => {
    if(opts.ctx.email) {
      this.items = await opts.ctx.get(
        '/git/items?email=' + encodeURIComponent(opts.ctx.email));

      this.update();
      M.Collapsible.init($('.collapsible'), {});
    } else {
      this.items = undefined;
      this.update();
    }
  });

  async showItemHolders(e) {
    const ranking = await opts.ctx.get(
      '/git/item-holders?item=' + encodeURIComponent(e.item.key));
    opts.ctx.showRanking(ranking, {header: e.item.key, showbadge: false});
  };
</items>
