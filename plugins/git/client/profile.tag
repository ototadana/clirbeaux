<profile>
  <div class="row" if={opts.ctx.email}>
    <div class="right-align" style="margin-top:12px;">
      <h5 class="right-align">{opts.ctx.email}</h5>
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
      font-size: 1.2em;
    }
  </style>

  opts.ctx.on('user-updated', () => {
    this.update();
  });

</profile>
