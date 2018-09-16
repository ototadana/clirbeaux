'use strict';
const yaml = require('js-yaml');
const util = require('util');
const readFile = util.promisify(require('fs').readFile);
const spawn = require('await-spawn');
const LineReader = require('line-by-line-promise');
const minimatch = require('minimatch');


const projectInfo = {};

const data = {
  projectPlayer: {
    all: [],
    map: {}
  },
  playerProject: {
    all: [],
    map: {}
  },
  languagePlayer: {
    all: [],
    map: {}
  },
  playerLanguage: {
    all: [],
    map: {}
  },
  playerMonth: {
    all: [],
    map: {}
  },
  monthPlayer: {
    all: [],
    map: {}
  },
  itemType: {
  },
  playerItem: {
  },
  itemPlayer: {
    all: [],
    map: {}
  },
  itemProject: {
    mapWithProjectList: {},
    map: {}
  }
};


const readConfig = async (envName, defaultValue) => {
  const fileName = process.env[envName] || defaultValue;
  const text = await readFile(fileName, 'utf8');
  return yaml.safeLoad(text);
};

const readFileTypeConfig = async () => {
  return await readConfig('FILE_TYPE_CONFIG', './config/file-type.yml');
};

const readProjectConfig = async () => {
  return await readConfig('PROJECT_CONFIG', './config/project.yml');
};

const getProjectInfo = (config) => {
  let info = projectInfo[config.name];
  if(info === undefined) {
    info = {name : config.name, line : 0};
    projectInfo[config.name] = info;
  }
  info.exclude = config.exclude;
  return info;
};

const readLogFile = async (projectInfo) => {
  const file = new LineReader('./tmp/' + projectInfo.name + '/log.txt');

  const lines = [];
  let count = 0;
  let line;
  while((line = await  file.readLine()) !== null) {
      count++;
      if(count > projectInfo.line) {
        lines.push(line);
      }
  }

  projectInfo.line = count;
  return lines;
};

const updateMapInternal = (map, key1, key2) => {
  let value1 = map[key1];
  if(value1 === undefined) {
    value1 = {};
    map[key1] = value1;
  }

  let value2 = value1[key2];
  if(value2 === undefined) {
    value2 = 0;
  }
  value1[key2] = value2 + 1;
};

const updateMap = (map, key1, key2) => {
  updateMapInternal(map.map, key1, key2);
  updateMapInternal(map.map, 'ALL', key2);
};

const updateItem = (map, player, item, type) => {
  let value = map[type];
  if(value === undefined) {
    value = {
      all:[],
      map:{}
    };
    map[type] = value;
  }
  updateMap(value, player, item);
  data.itemType[item] = type;
};


const getItem = (fileType, line) => {
  if(!fileType.item || !fileType.item.matcher || !fileType.item.bundle) {
    return null;
  }

  if(!fileType.item.matcherRe) {
    fileType.item.matcherRe = [];
    for(let i = 0; i < fileType.item.matcher.length; i++) {
      fileType.item.matcherRe.push(new RegExp(fileType.item.matcher[i]));
    }
  }

  let name = null;
  for(let i = 0; i < fileType.item.matcherRe.length; i++) {
      const re = fileType.item.matcherRe[i];
      const result = re.exec(line);
      if(result && result.length > 1) {
        name = result[1];
        break;
      }
  }

  if(name == null) {
    return null;
  }

  if(fileType.item.exclude) {
    for(let i = 0; i < fileType.item.exclude.length; i++) {
      if(minimatch(name, fileType.item.exclude[i])) {
        return null;
      }
    }
  }

  for(let i = 0; i < fileType.item.bundle.length; i++) {
    const itemInfo = fileType.item.bundle[i];
    for(let j = 0; j < itemInfo.pattern.length; j++) {
      if(minimatch(name, itemInfo.pattern[j])) {
        return itemInfo.type;
      }
    }
  }

  return name;
};

const updateData = (month, player, projectName, fileName, fileType, line) => {
  updateMap(data.projectPlayer, projectName, player);
  updateMap(data.playerProject, player, projectName);
  updateMap(data.playerLanguage, player, fileType.type);
  updateMap(data.languagePlayer, fileType.type, player);
  updateMap(data.playerMonth, player, month);
  updateMap(data.monthPlayer, month, player);

  const item = getItem(fileType, line);
  if(item) {
    updateItem(data.playerItem, player, item, fileType.type);
    updateMap(data.itemPlayer, item, player);
    updateMap(data.itemProject, item, projectName);
  }
};

const getFileType = (fileName, fileTypes, exclude) => {
  if(exclude) {
    for(let i = 0; i < exclude.length; i++) {
      if(minimatch(fileName, exclude[i])) {
        return null;
      }
    }
  }

  for(let i = 0; i < fileTypes.length; i++) {
    const fileType = fileTypes[i];
    for(let j = 0; j < fileType.pattern.length; j++) {
      if(minimatch(fileName, fileType.pattern[j], {matchBase:true})) {
        return fileType;
      }
    }
  }
  return null;
};

const updateDataByLogLines = (logLines, projectInfo, fileTypes) => {
  let month = null;
  let player = null;
  let fileName = null;
  let fileType = null;

  for(let i = 0; i < logLines.length; i++) {
    const line = logLines[i];

    if(line.startsWith('===')) {
      const s = line.split(';');
      month = s[1].substring(0, 7);
      player = s[2];
    } else if(line.startsWith('+++ ')) {
      fileName = line.substring(5);
      fileType = getFileType(fileName, fileTypes, projectInfo.exclude);
    } else {
      if(fileType != null) {
        updateData(month, player, projectInfo.name, fileName, fileType, line);
      }
    }
  }
};

const updateDataByLog = async (config, fileTypes) => {
  const projectInfo = getProjectInfo(config);
  const commit = await readFile('./tmp/' + config.name + '/last-commit.txt', 'utf8');
  if(commit === projectInfo.commit) {
    return;
  }

  const logLines = await readLogFile(projectInfo);
  updateDataByLogLines(logLines, projectInfo, fileTypes);
  projectInfo.commit = commit;
};

const updateLogFile = async (config) => {
  var branch = config.branch || 'master';
  await spawn('sh', ['./sh/update-log-file.sh', config.name, config.url, branch], {stdio: 'inherit'});
};

const updateAllList = (obj, comparator) => {
  if(!comparator) {
    comparator = (a,b)=>b[1]-a[1];
  }
  const allMap = obj.map['ALL'];
  if(allMap == undefined) {
    return;
  }
  obj.all = Array.from(Object.entries(allMap))
    .sort(comparator)
    .map(e=>{return {key:e[0], value:e[1]}});
};

const updateAllListForItem = (obj) => {
  const arr = Object.values(obj);
  for(let i = 0; i < arr.length; i++) {
    updateAllList(arr[i]);
  }
};

const updateItemProject = (itemProject) => {
  const list =
    Array.from(Object.entries(itemProject.map))
      .map(e=>{
        return {
          key: e[0],
          value: Array.from(Object.entries(e[1])).sort((a,b)=>b[1]-a[1]).map(f=>f[0])
        }
      });
  const map = {};
  for(let i = 0; i < list.length; i++) {
    map[list[i].key] = list[i].value;
  }
  itemProject.mapWithProjectList = map;
};

const updateAllData = async () => {
  const projectConfig = (await readProjectConfig()).project;
  const fileTypes = (await readFileTypeConfig()).fileType;
  for(let i = 0; i < projectConfig.length; i++) {
    await updateLogFile(projectConfig[i]);
    await updateDataByLog(projectConfig[i], fileTypes);
  }
  updateAllList(data.projectPlayer);
  updateAllList(data.playerProject);
  updateAllList(data.playerLanguage);
  updateAllList(data.playerMonth, (a,b)=>a[0].localeCompare(b[0]));
  updateAllList(data.monthPlayer);
  updateAllListForItem(data.playerItem);
  updateAllList(data.itemPlayer);
  updateItemProject(data.itemProject);
};

const toRanking = (obj, allObj, key) => {
  const map = obj.map[key];
  return Array.from(Object.entries(map))
    .sort((a,b)=>b[1]-a[1])
    .map(e=>{return {key:e[0], value:e[1], all:allObj.map.ALL[key]}});
};

const toResult = (obj, key) => {
  const map = obj.map[key];
  return obj.all.map(e=>{return {key:e.key, value:map[e.key], all:e.value}});
};


const update = async (ctx, next) => {
  try {
    await updateAllData();
    const text = yaml.safeDump(data);
    require('fs').writeFileSync('./tmp/dump.txt', text);
    console.log('Done: ' + new Date());
  } catch(e) {
    console.log(e);
    console.log('Failed: ' + new Date());
  }
};

const getContributes = async (ctx, next) => {
  ctx.body = toResult(data.playerProject, ctx.request.query.email);
  ctx.status = 200;
};

const getSkills = async (ctx, next) => {
  ctx.body = toResult(data.playerLanguage, ctx.request.query.email);
  ctx.status = 200;
};

const getItems = async (ctx, next) => {
  const player = ctx.request.query.email;
  const results = [];
  const types = Object.entries(data.playerItem);
  for(let i = 0; i < types.length; i++) {
    const type = types[i][0];
    const value = types[i][1];
    const map = value.map[player];
    const items = value.all.map(e=>{
      return {
        key: e.key,
        value: map? map[e.key] : 0,
        projects: data.itemProject.mapWithProjectList[e.key]
      }
    });
    results.push({
      type: type,
      items: items
    });
  }

  ctx.body = results;
  ctx.status = 200;
};


const getMonthlyLines = async (ctx, next) => {
  ctx.body = toResult(data.playerMonth, ctx.request.query.email);
  ctx.status = 200;
};

const getPlayerRankingOfMonth = async (ctx, next) => {
  ctx.body = toRanking(data.monthPlayer, data.playerMonth, ctx.request.query.month);
  ctx.status = 200;
};

const getContributers = async (ctx, next) => {
  ctx.body = toRanking(data.projectPlayer, data.playerProject, ctx.request.query.project);
  ctx.status = 200;
};

const getLanguageMasters = async (ctx, next) => {
  ctx.body = toRanking(data.languagePlayer, data.playerLanguage, ctx.request.query.language);
  ctx.status = 200;
};

const getItemHolders = async (ctx, next) => {
  const item = ctx.request.query.item;
  const type = data.itemType[item];
  ctx.body = toRanking(data.itemPlayer, data.playerItem[type], item);
  ctx.status = 200;
};

const calcProgress = (exp, level, nextLevel) => {
  return (exp - level) / (nextLevel - level);
};

const getLevel = async (ctx, next) => {
  const exp = Math.floor(data.projectPlayer.map.ALL[ctx.request.query.email] / 20);

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

module.exports.route = (router) => {
  router
    .get('/git/level', getLevel)
    .get('/git/item-holders', getItemHolders)
    .get('/git/language-masters', getLanguageMasters)
    .get('/git/contributers', getContributers)
    .get('/git/player-ranking-of-month', getPlayerRankingOfMonth)
    .get('/git/monthly-lines', getMonthlyLines)
    .get('/git/items', getItems)
    .get('/git/contributes', getContributes)
    .get('/git/skills', getSkills);

  const updateIntervalMin = process.env.UPDATE_INTERVAL_MIN || 60;
  setInterval(() => {
    update();
  }, updateIntervalMin * 60 * 1000);

  update();
};
