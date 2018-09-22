'use strict';
const axios = require('axios');
const url = require('url');

const taigaUrl = url.resolve(process.env.TAIGA_URL, 'api/v1/');

const getTaigaUser = async (user, password) => {
  const response = await axios.post(taigaUrl + 'auth', {
    type: 'ldap',
    username: user,
    password: password
  }, {
    headers: {
      'Content-Type': 'application/json'
    }
  });

  return response.data;
};

const getHeaders = (authToken) => {
  return {
      'Authorization': 'Bearer ' + authToken,
      'Content-Type': 'application/json',
      'x-disable-pagination': 'True'
    };
}

const projectMap = {};
const getProject = async (authToken, id) => {
  let project = projectMap[id];

  if(!project) {
    const response = await axios.get(taigaUrl + 'projects/' + id, {
      headers: getHeaders(authToken)
    });
    project = response.data.slug;
    projectMap[id] = project;
  }

  return project;
};

const summarizeTask = async (authToken, task) => {
  const usInfo = task.user_story_extra_info;
  const project = await getProject(authToken, task.project);
  const projectUrl = url.resolve(process.env.TAIGA_URL, 'project/' + project);
  const taskUrl = projectUrl + '/task/' + task.ref;
  const usUrl = usInfo? (projectUrl + '/us/' + usInfo.ref) : taskUrl;
  return {
    ref: task.ref,
    taskUrl: taskUrl,
    usUrl: usUrl,
    subject: task.subject,
    us: usInfo? usInfo.subject : task.subject
  };
};

const getOpenTasks = async (authToken, uid) => {
  const response = await axios.get(taigaUrl + 'tasks?status__is_closed=false&assigned_to=' + uid, {
    headers: getHeaders(authToken)
  });

  const tasks = {};
  for(let i = 0; i < response.data.length; i++) {
    const name = response.data[i].status_extra_info.name;
    let entry = tasks[name];
    if(entry == undefined) {
      entry = {
        status: name,
        data: [],
        count: 1
      };
    } else {
      entry.count = entry.count + 1;
    }
    entry.data.push(await summarizeTask(authToken, response.data[i]));
    tasks[name] = entry;
  }
  return Object.values(tasks);
};

const getClosedTasks = async (authToken, uid) => {
  const response = await axios.get(taigaUrl + 'tasks?status__is_closed=true&assigned_to=' + uid, {
    headers: getHeaders(authToken)
  });

  return response.data;
};

const getOwnedIssues = async (authToken, uid) => {
  const response = await axios.get(taigaUrl + 'issues?owner=' + uid, {
    headers: getHeaders(authToken)
  });

  return response.data;
};

const getClosedTaskCount = async (authToken, uid) => {
  return (await getClosedTasks(authToken, uid)).length;
};

const getOwnedIssueCount = async (authToken, uid) => {
  return (await getOwnedIssues(authToken, uid)).length;
};

const getLength = (num) => {
  return Math.floor(Math.log(num)/Math.log(10))+1;
};

const getSnakeEyes = (length) => {
  let num = 0;
  for(let i = 0; i < length; i++) {
    num = num + Math.pow(10, i);
  }
  return num;
};

const isNiceRoundNumber = (ref, length) => {
  return Math.pow(10, length-1) === ref;
};

const isRepdigit = (ref, length) => {
  return length > 2 && ref%getSnakeEyes(length) === 0;
};

const isTreasure = (ref) => {
  const length = getLength(ref);
  return isNiceRoundNumber(ref, length) || isRepdigit(ref, length);
};

const findTreasureFromClosedTasks = async (authToken, uid) => {
  const tasks = await getClosedTasks(authToken, uid);
  const tresureTasks = tasks.filter(t => isTreasure(t.ref));
  const results = [];
  for(let i = 0; i < tresureTasks.length; i++) {
    results.push(await summarizeTask(authToken, tresureTasks[i]));
  }
  return results;
};

const calcProgress = (exp, level, nextLevel) => {
  return (exp - level) / (nextLevel - level);
};

const getProfile = async (ctx, next) => {
  const user = ctx.request.query.user;
  const password = ctx.request.query.password;

  ctx.body = await getTaigaUser(user, password);
  ctx.status = 200;
};

const getTasks = async (ctx, next) => {
  const authToken = ctx.request.query.authToken;
  const uid = ctx.request.query.uid;

  ctx.body = await getOpenTasks(authToken, uid);
  ctx.status = 200;
};

const getLevel = async (ctx, next) => {
  const authToken = ctx.request.query.authToken;
  const uid = ctx.request.query.uid;

  const closedTaskCount = await getClosedTaskCount(authToken, uid);
  const ownedIssueCount = await getOwnedIssueCount(authToken, uid);
  const exp = Math.floor(closedTaskCount + ownedIssueCount*1.5);

  let level = 1;
  let progress = 0;
  if(exp >= 100) {
    let addLevel = Math.floor((exp - 100) / 50)
    let currentBaseExp = 100 + addLevel * 50;
    level = 7 + addLevel;
    progress = calcProgress(exp, currentBaseExp, currentBaseExp + 50);
  } else if(exp >= 80) {
    level = 6;
    progress = calcProgress(exp, 80, 100);
  } else if(exp >= 50) {
    level = 5;
    progress = calcProgress(exp, 50, 80);
  } else if(exp >= 20) {
    level = 4;
    progress = calcProgress(exp, 20, 50);
  } else if(exp >= 10) {
    level = 3;
    progress = calcProgress(exp, 10, 20);
  } else if(exp >= 1) {
    level = 2;
    progress = calcProgress(exp, 1, 10);
  } else {
    level = 1;
    progress = calcProgress(exp, 0, 1);
  }

  ctx.body = {
    level: level,
    progress: progress,
    exp: exp
  };
  ctx.status = 200;
};

const getTreasures = async (ctx, next) => {
  const authToken = ctx.request.query.authToken;
  const uid = ctx.request.query.uid;
  ctx.body = await findTreasureFromClosedTasks(authToken, uid);
  ctx.status = 200;
};

module.exports.route = (router) => {
  router
    .get('/taiga/treasures', getTreasures)
    .get('/taiga/profile', getProfile)
    .get('/taiga/level', getLevel)
    .get('/taiga/tasks', getTasks);
};
