<item>
  <div class="row item {holder : opts.count > 0}" title={opts.count}>
    <div class="col l6 m12 item-key">
      <span if={!(opts.count > 0)}>&#x2610;</span>
      <span if={opts.count > 0}>&#x2611;</span>
      {opts.key}
    </div>
    <div class="col l6 m12">
      <ul>
        <li each={project in opts.projects}>
          <div class="project">{project}</div>
        </li>
      </ul>
    </div>
  </div>
  <style>
    ul {
      margin: 0px;
    }
    ul, li, div.item-key {
      display: inline;
    }

    .row {
      margin-bottom: 4px;
    }

    .item.holder {
      background-color: #ffffff;
    }

    .item-key {
      color: #a0a0a0;
    }

    .holder .item-key {
      color: black;
      font-weight: bold;
    }

    .project {
      font-size: 0.8em;
      padding: 1px 6px 1px 6px;
      text-align: center;
      display:inline-block;
      margin: 0px;
      background-color: #ffcccc;
    }
  </style>

</item>
