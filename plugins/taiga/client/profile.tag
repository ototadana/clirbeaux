<profile>
  <div class="row" if={opts.ctx.email && !user}>
    <spinner></spinner>
  </div>

  <div class="row" if={user}>
    <div class="right-align" style="margin-top:12px;">
      <img src={user.big_photo}>
      <h5 class="right-align">{user.username}</h5>
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
    if(opts.ctx.taiga.user) {
      this.user = opts.ctx.taiga.user;
    } else {
      this.user = undefined;
    }

    this.update();
  });
</profile>
