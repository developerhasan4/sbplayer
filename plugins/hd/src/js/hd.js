(function(jwplayer) {


/**
* Displays an HD/SD quality toggle.
**/
var template = function(_player, _options, _div) {


    /** Icon to display when HD is on. **/
    var _iconOn = '../assets/is_on.png';
    /** Icon to display when HD is off. **/
    var _iconOff = '../assets/is_off.png';
    /** Currently active playlist item. **/
    var _item;
    /** Player just reloaded playlist. **/
    var _loaded;
    /** The current position in the video. **/
    var _position;
    /** Position to seek to after a switch. **/
    var _seek;
    /** Current HD state. **/
    var _state;


    /** Play the HD quality video. **/
    function _buttonHDHandler() {
        _startHD(true);
    };


    /** Play the SD quality video. **/
    function _buttonSDHandler() {
        _startSD(true);
    };


    /** Reset position when video completed. **/
    function _completeHandler() {
        _position = 0;
    };


    /** Copy the playlist, stripping out any non-string values. **/
    function _copyList(list,hd) {
        var copy = [];
        // Clean the playlist, since complex data is sometimes stored.
        for (var i=0; i<list.length; i++) {
            var entry = {};
            for(var key in list[i]) {
                if(typeof(list[i][key]) == 'string' || typeof(list[i][key]) == 'number') {
                    entry[key] = list[i][key];
                }
            }
            // Switch SD > HD or vice versa
            if(hd) {
                entry['hd.original'] = list[i].file;
                if(list[i]['hd.file']) {
                    entry['file'] = list[i]['hd.file'];
                }
            } else { 
                entry['file'] = list[i]['hd.original'];
            }
            copy.push(entry);
        }
        return copy;
    };


    /** Toggle HD setup. **/
    var dockHandler = function() {
        if(_player.getPlaylistItem(_item)['hd.file']) {
            if(_state) {
                _startSD(true);
            } else {
                _startHD(true);
            }
        }
    };


    /** Check if fullscreen option is used. **/
    function _fullscreenHandler(event) {
        if(event.fullscreen && _options.fullscreen && !_state) {
            _startHD(true);
        }
    };


    /** Ignore HD for Touch devices. **/
    function _isTouch() {
        var agent = navigator.userAgent.toLowerCase();
        if (agent.match(/ip(hone|ad|od)/i) !== null || 
            agent.match(/android/i) !== null) {
            return true;
        } else {
            return false;
        }
    };


    /** Check if the new playlist item has an HD version. **/
    function _itemHandler(event) {
        _item = event.index;
        if(_player.getPlaylistItem(_item)['hd.file']) {
            if(_state) {
                _player.getPlugin("dock").setButton('hd',dockHandler,_iconOn);
            } else { 
                _player.getPlugin("dock").setButton('hd',dockHandler,_iconOff);
            }
        } else {
            _player.getPlugin("dock").setButton('hd');
        }
    };


    /** Seek to correct position if still outstanding. **/
    function _playHandler(event) {
        if(_seek && _seek > 5) {
            setTimeout(_playSeek,1000);
        }
    };


    /** Do the seek after a switch. **/
    function _playSeek() { 
        _player.seek(_seek);
        _seek = 0;
    };


    /** Restart video if playlist loaded b/c of switch. **/
    function _playlistHandler(event) {
        if(_loaded) {
            _player.playlistItem(_item);
            _loaded = false;
        }
    };


    /** Set dock buttons when player is ready. **/
    function _readyHandler() {
        if(_player.getRenderingMode() == 'flash' || _isTouch()) { return; }
        // Inject HD file when available.
        if(_options.file && !_player.getPlaylist()[0]['hd.file']) {
            _player.getPlaylist()[0]['hd.file'] = _options.file;
        }
        if(_options.state == true) { 
            _startHD(false);
        } else if (_options.state == false) { 
            _startSD(false);
        } else if(document.cookie.indexOf('jwplayerhdstate=true') > -1) {
            _startHD(false);
        } else  {
            _startSD(false);
        }
        // Subscribe to events.
        _player.onPlay(_playHandler);
        _player.onPlaylist(_playlistHandler);
        _player.onPlaylistItem(_itemHandler);
        _player.onTime(_timeHandler);
        _player.onComplete(_completeHandler);
        _player.onFullscreen(_fullscreenHandler);
    };
    _player.onReady(_readyHandler);


    /** Reposition buttons upon a resize. **/
    this.resize = function(wid,hei) {
        if(_player.getRenderingMode() == 'flash' || _isTouch()) { return; }
    };


    /** Set cookie to store HD state. **/
    function _setCookie(state) {
        var cookie = 'jwplayerhdstate=' + state + '; ';
        cookie += 'expires=Wed, 1 Jan 2020 00:00:00 UTC; ';
        cookie += 'path=/';
        document.cookie = cookie;
    };


    /** Reload the playlist in HD mode. **/
    function _startHD(play) {
        if(!_isTouch()) {
            _player.getPlugin("dock").setButton('hd',dockHandler,_iconOn);
        }
        if(!_state) {
            var list = _copyList(_player.getPlaylist(), true);
            _state = true;
            if(play) { 
                _seek = _position;
                _loaded = true; 
            }
            _player.load(list);
            _setCookie(true);
        } else if (play) {
            _player.play(true);
        }
    };


    /** Reload the playlist in SD mode. **/
    function _startSD(play) {
        if(!_isTouch()) {
            _player.getPlugin("dock").setButton('hd',dockHandler,_iconOff);
        }
        if(_state) {
            var list = _copyList(_player.getPlaylist(), false);
            _state = false;
            if(play) { 
                _seek = _position;
                _loaded = true;
            }
            _player.load(list);
            _setCookie(false);
        } else if (play) {
            _player.play(true);
        }
    };


    /** Apply CSS styles to elements. **/
    function _style(element,styles) {
        for(var property in styles) {
          element.style[property] = styles[property];
        }
     };


    /** Store the last position, for quick recovery. **/
    function _timeHandler(event) {
        _position = event.position;
    };


};


/** Register the plugin with JW Player. **/
jwplayer().registerPlugin('hd', template,'./hd.swf');


})(jwplayer);