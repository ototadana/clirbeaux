<user-dialog>
  <div id="user-dialog" class="modal">
    <div class="modal-content">
      <div class="row">
        <div class="input-field col s12">
          <i class="material-icons prefix">email</i>
          <input id="email" type="text" class="validate">
          <label for="email">Email</label>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="modal-action modal-close waves-effect waves-green btn-flat" onclick={updateUser}>OK</button>
    </div>
  </div>
  <style>
    .modal-close {
      border: solid 1px gray;
    }
  </style>

  this.on('mount', () => {
    const instance = M.Modal.init($('#user-dialog'), {
      onOpenEnd: () => {
        const user = opts.ctx.load('git.user');

        if(!$("#email").val() && user && user.email) {
          $("#email").val(user.email);
        }

        $("#user").focus();
        M.updateTextFields();
      }
    });

    if(!opts.ctx.email) {
      instance[0].open();
    }
  });

  updateUser(e) {
    e.preventDefault();
    opts.ctx.email = $('#email').val();
    opts.ctx.save('git.user', {
      email: opts.ctx.email
    });
    opts.ctx.trigger('user-updated');
  }

</user-dialog>
<user-button>
  <a id="user-button" href="#user-dialog" class="modal-trigger">User</a>
</user-button>
