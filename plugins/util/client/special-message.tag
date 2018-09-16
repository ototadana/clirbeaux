<special-message>
  <div class="modal">
    <div class="modal-content">
      <div><h1></h1></div>
    </div>
  </div>
  <style>
    .modal {
      border-radius: 10px;
      overflow: hidden;
    }

    h1 {
      margin:0px;
      animation: slidin 1.5s linear;
      color: #888888;
      font-weight: bold;
    }

    @keyframes slidin {
      0% {
        transform: translateX(100%);
        opacity: 0;
      }
      30% {
        transform: translateX(0%);
        opacity: 1;
      }
      50% {
        opacity: 0.2;
      }
      100% {
        opacity: 1;
      }
    }
  </style>

  this.on('mount', () => {
    M.Modal.init($('.modal'));
  });

  opts.ctx.showSpecialMessage = (message) => {
    $('special-message .modal h1').text(message);
    var instance = M.Modal.getInstance(document.querySelector('special-message .modal'));
    instance.open();
    setTimeout(() => {
      instance.close();
    }, 3000);
  };

</special-message>
