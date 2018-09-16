const ctx = () => {
  var ctx = {};
  riot.observable(ctx);

  ctx.load = (key) => {
    var value = localStorage.getItem(key);
    if(value) {
      try {
        return JSON.parse(value);
      } catch(e) {
        localStorage.removeItem(key);
      }
    }
    return {};
  };

  ctx.save = (key, value) => {
    localStorage.setItem(key, JSON.stringify(value));
  };

  ctx.loadPlayerData = async (type) => {
    return await ctx.get(
      '/util/player-data?player=' + encodeURIComponent(ctx.email) + '&type=' + encodeURIComponent(type)
    );
  };

  ctx.get = async (url) => {
    try {
      return await $.ajax({url: url, type: 'GET', dataType: 'json'});
    } catch(e) {
      console.log(e);
      return {};
    }
  };

  ctx.savePlayerData = async (type, data) => {
    try {
      await $.ajax({
        url: '/util/player-data',
        type: 'POST',
        dataType: 'json',
        data: {
          player: ctx.email,
          type: type,
          data: data
        }
      });
    } catch(e) {
      console.log(e);
    }
  };

  ctx.showMessage = (message) => {
    M.toast({html: message})
  };


  return ctx;
}