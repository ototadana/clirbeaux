<badge>
  <div class="badge { label } { opts.highlight }">
    <div class="badge-key">{ opts.key }</div>
    <div class="badge-value" title="{ opts.count }">{ label }</div>
  </div>
  <style>
    .badge {
      border: solid 1px #cccccc;
      border-radius: 6px;
      display:inline-block;
      padding: 0px;
      margin: 2px;
    }

    .badge.highlight {
      animation: blink .5s step-end 10 alternate;
    }

    @keyframes blink {
      50% {
        opacity: 0.5;
        box-shadow: 0 0 8px gray;
      }
    }

    .badge div {
      padding-left: 6px;
      padding-right: 6px;
      text-align: center;
    }

    .badge-key {
      font-size: 0.8em;
      background-color: white;
      color: gray;
      border-radius: 6px 6px 0 0 / 6px 6px 0 0;
    }

    .badge-value {
      font-size: 1em;
    }

    .badge.Authority {
      color: #FFD700;
      background-color: #996515;
      font-weight: bold;
    }

    .badge.Expert {
      color: white;
      background-color: green;
    }

    .badge.Advanced {
      color: black;
      background-color: lightgreen;
    }

    .badge.Skillful {
      color: black;
      background-color: #ffffaa;
    }

    .badge.Intermediate {
      color: gray;
      background-color: #ffffe0;
    }

    .badge.Beginner {
      color: gray;
      background-color: #eeeeee;
    }

    .badge.Ignorant {
      color: #eeeeee;
      background-color: #eeeeee;
    }
  </style>

  this.on('before-mount', () => {
    this.label = this.toLabel(opts.key, opts.count, opts.all);
  });

  toLabel(key, value, allValue) {
    if(value / allValue > 0.5) {
      return 'Authority';
    } else if(value >= 10000) {
      return 'Expert';
    } else if(value >= 5000) {
      return 'Advanced';
    } else if(value >= 1000) {
      return 'Skillful';
    } else if(value >= 100) {
      return 'Intermediate';
    } else if(value > 0) {
      return 'Beginner';
    } else {
      return 'Ignorant';
    }
  };
</badge>
