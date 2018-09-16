<user-dialog>
  <div id="user-dialog" class="modal">
    <div class="modal-content">
      <div class="row">
        <div class="input-field col s12">
          <i class="material-icons prefix">person</i>
          <input id="user" type="text" class="validate">
          <label for="user">User Id</label>
        </div>
      </div>
      <div class="row">
        <div class="input-field col s12">
          <i class="material-icons prefix">security</i>
          <input id="password" type="password" class="validate">
          <label for="password">Password</label>
        </div>
        <div class="row" if={error}>
          <div class="input-field col s12">
            <p>{error}</p>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="modal-action modal-close waves-effect waves-green btn-flat" onclick={updateUser}>Login</button>
    </div>
  </div>
  <style>
    .modal-close {
      border: solid 1px gray;
    }
  </style>

  this.on('mount', () => {
    var instance = M.Modal.init($('#user-dialog'), {
      onOpenEnd: () => {
        user = opts.ctx.load('taiga.user');

        if(!$("#user").val() && user && user.userId) {
          $("#user").val(user.userId);
        }
        if(!$("#password").val() && user && user.password) {
          $("#password").val(user.password);
        }

        $("#user").focus();
        M.updateTextFields();
      }
    });

    if(opts.ctx.email) {
      instance[0].open();
    }
  });

  async updateUser(e) {
    e.preventDefault();

    if(!opts.ctx.taiga) {
      opts.ctx.taiga = {};
    }
    const userId = $("#user").val();
    const password = $("#password").val();

    opts.ctx.taiga.user = await opts.ctx.get(
      '/taiga/profile?user=' + 
        encodeURIComponent(userId) +
        '&password=' + encodeURIComponent(password));

    if(opts.ctx.taiga.user.email) {
      $('#user-button').text('Logout');
      opts.ctx.save('taiga.user', {
        userId: userId,
        password: password
      });
      opts.ctx.email = opts.ctx.taiga.user.email;
      opts.ctx.trigger('user-updated');
      this.error = '';
      this.update();
    } else {
      this.error = 'Invalid user or password';
      this.update();
      M.Modal.getInstance($('#user-dialog')).open();
    }
  }
</user-dialog>
<user-button>
  <a id="user-button" href="#!" class="modal-action" onclick={openDialog}>Login</a>

  async openDialog(e) {
    var userButton = $('#user-button');
    var command = userButton.text();

    if(command === 'Login') {
      var instance = M.Modal.getInstance(document.querySelector('#user-dialog'));
      instance.open();
    } else {
      console.log(e);
      opts.ctx.taiga.user = undefined;
      opts.ctx.email = undefined;
      userButton.text('Login');
      this.update();
      opts.ctx.trigger('user-updated');
    }
  }
</user-button>
