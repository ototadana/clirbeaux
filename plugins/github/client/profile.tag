<profile>
  <div class="row" if={opts.ctx.userId && !user}>
    <spinner></spinner>
  </div>
  <div class="row" if={user}>
    <div class="right-align" style="margin-top:12px;">
      <img src={user.avatar_url}>
      <h5 class="right-align">{user.name}</h5>
    </div>
  </div>
  <style>
    :scope {
      color: #888;
    }

    img {
      width: 200px;
      height: 200px;
    }

    h5 {
      padding-top: 0px;
      margin-top: 0px;
      font-size: 1em;
    }
  </style>

  opts.ctx.on('user-updated', async () => {
    this.user = await opts.ctx.get(
      'https://api.github.com/users/' + encodeURIComponent(opts.ctx.userId));
    riot.update();
  });
</profile>
