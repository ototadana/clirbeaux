'use strict';
const util = require('util');
const fs = require('fs');
const readFile = util.promisify(fs.readFile);
const mkdirp = require('mkdirp-promise');

const getFile = async (playerData) => {
  const playerDir = './data/' + playerData.player;
  await mkdirp(playerDir);
  return playerDir + '/' + playerData.type + '.json';
};

const loadPlayerData = async (ctx, next) => {
  const playerData = {
    player: ctx.request.query.player,
    type: ctx.request.query.type
  };

  let data = {};
  try {
    const file = await getFile(playerData);
    data = JSON.parse(await readFile(file, 'utf8'));
  } catch(e) {
    console.log(e);
  }

  ctx.body = data;
  ctx.status = 200;
};

const savePlayerData = async (ctx, next) => {
  const playerData = ctx.request.body;
  try {
    const file = await getFile(playerData);
    fs.writeFileSync(file, JSON.stringify(playerData.data));
  } catch(e) {
    console.log(e);
  }

  ctx.body = {message: 'OK'};
  ctx.status = 200;
};

module.exports.route = (router) => {
  router
    .get('/util/player-data', loadPlayerData)
    .post('/util/player-data', savePlayerData);
};
