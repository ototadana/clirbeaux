<tasks>
  <div class="row">
    <div if={opts.ctx.email && !tasks}>
      <spinner></spinner>
    </div>
    <div if={tasks && tasks.length > 0}>
      <h4>Tasks</h4>
      <table>
        <tr>
          <th each={tasks} class="right-align">{status}</th>
        </tr>
        <tr>
          <td each={tasks} class="right-align" title={detail}>{count}</td>
        </tr>
      </table>
    </div>
  </div>
  <style>
    :scope {
      color: #888;
    }
  </style>

  opts.ctx.on('user-updated', async () => {
    if(!opts.ctx.taiga.user) {
      this.tasks = undefined;
      this.update();
      return;
    }

    this.tasks = await opts.ctx.get(
      '/taiga/tasks?authToken=' + 
        encodeURIComponent(opts.ctx.taiga.user.auth_token) +
        '&uid=' + encodeURIComponent(opts.ctx.taiga.user.id));

    this.tasks.forEach((taskType) => {
      const taskCount = {};
      taskType.data.forEach((task) => {
        if(taskCount[task.us] == undefined) {
          taskCount[task.us] = 0;
        }
        taskCount[task.us] = taskCount[task.us] + 1;
      });
      const taskDetail = [];
      Object.keys(taskCount).forEach(function(us){
        taskDetail.push(us + ':' + taskCount[us]);
      });
      taskType.detail = taskDetail.join('\n');
    });

    this.update();
  });

</tasks>
