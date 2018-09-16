<ranking>
  <div class="modal modal-fixed-footer">
    <div class="modal-content">
      <div if={!ranking}>
        <spinner></spinner>
      </div>
      <div if={ranking}>
        <h1 class="orange darken-1">{header}</h1>
        <div class="row" each={ obj, i in ranking }>
          <div class="col s1">{ i + 1 }.</div>
          <div class="col s7">{ obj.key }</div>
          <div class="col s4" if={ showbadge }>
            <badge key="" count="{ obj.value }" all="{ obj.all }"></badge>
          </div>
          <div class="col s4" if={ !showbadge }>{ obj.value }</div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <a href="#!" class="modal-close waves-effect waves-green btn-flat">OK</a>
    </div>
  </div>
  <style>
    h1 {
      font-size: 2em;
      padding: 6px;
      color: white;
    }
    div.row {
      margin-bottom: 6px;
      margin-left: 12px;
    }
    a.modal-close {
      border: solid 1px gray;
    }
  </style>

  this.on('mount', () => {
    M.Modal.init($('.modal'));
  });

  opts.ctx.showRanking = (arr, option) => {
    if(option.header) {
      this.header = option.header;
    }
    this.showbadge = option.showbadge;
    if(arr && arr.length > 10) {
      arr.length = 10;
    }
    this.ranking = arr;
    this.update();

    var instance = M.Modal.getInstance(document.querySelector('ranking .modal'));
    instance.open();
  }
</ranking>
