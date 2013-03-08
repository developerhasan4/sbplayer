package {


    import com.longtailvideo.jwplayer.events.*;
    import com.longtailvideo.jwplayer.model.*;
    import com.longtailvideo.jwplayer.player.*;
    import com.longtailvideo.jwplayer.plugins.*;
    import com.longtailvideo.jwplayer.utils.*;
    import com.longtailvideo.jwplayer.view.components.DropDownList;
    import com.longtailvideo.jwplayer.view.components.DropDownListItem;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.xml.XMLNode;
    
   

    /** HD Plugin; implements an HD toggle. **/
    public class HD extends MovieClip implements IPlugin{


        /** Reference to the dock/controlbar button. **/
        private var _button:MovieClip;
		
		private var _list:MovieClip;
        /** Reference to the plugin's configuration **/
        private var _config:PluginConfig;
        /** Is HD set for this playlistitem. **/
        private var _isset:Boolean;
        /** Item whose startposition to reset. **/
        private var _reset:Number;
        /** Reference to the player. **/
        private var _player:IPlayer;
        /** The current position inside a video. **/
        private var _position:Number;
        private var _icon:DropDownListItem;
		
		private var src:String;
		
		
		private var files:Object;


        /** Constructor; nothing going on. **/
        public function HD():void {}


        /** Controlbar/dock button is clicked, so toggle the HD state. **/
        private function _clickHandler(event:MouseEvent):void {
            if(_isset) { 
                _config.state = !_config.state;
                Configger.saveCookie('hd.state',_config.state);
            //    _swap();
            }
        };


        /** Reset any start position on complete. **/
        private function _completeHandler(event:MediaEvent):void { 
            if(_reset > -1) {
                _player.playlist.getItemAt(_reset).start = 0;
                _reset = -1;
            }
        };


        /** Identifier of the plugin. **/
        public function get id():String {
            return 'hd';
        };


        /** The initialize call is invoked by the player. **/
        public function initPlugin(player:IPlayer, config:PluginConfig):void {
            _player = player;
            _config = config;
            // Add event listeners.
            
			
			//var _item:PlaylistItem = _player.playlist.currentItem;
		//	_config['files'] = (_config['files']!=undefined) ? _config['files'] : _item['hd.files'];
			//Logger.log(_config['files'],'hd');
			files = {};
			parseConfig();
			
			if(files['default'] == undefined)
				return;
			
			
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE,_completeHandler);
			//   _player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, _itemHandler);
			//  _player.addEventListener(MediaEvent.JWPLAYER_MEDIA_META,_metaHandler);
			// _player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, _playlistHandler);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, _timeHandler);
			
			
			
			
		

			src = files['default']['file'];
			
			
			 _icon = new DropDownListItem(45,27,files['default']);
		    _player.controls.controlbar.addButton(_icon, 'hd', _clickHandler);
			
			_button = _player.controls.controlbar.getButton('hd') as MovieClip;
			
			_button.addEventListener(MouseEvent.MOUSE_OVER,onMouseHandler);
			_button.addEventListener(MouseEvent.MOUSE_OUT,onMouseHandler);

			_list = new DropDownList();
			_list.init();
			for (var key:String in files){
				if(key!='default')
					_list.addItem(files[key]);
			}
			_list.visible = false;
			_list.addEventListener(ViewEvent.JWPLAYER_VIEW_CLICK,onListClick);
			_list.addEventListener(MouseEvent.MOUSE_OVER,onMouseHandler);
			_list.addEventListener(MouseEvent.MOUSE_OUT,onMouseHandler);
			DisplayObjectContainer(_player.controls.controlbar).addChild(_list as DisplayObject);
			_list.setActive(files['default']['label']);
			_list.y = 0;
            // Set initial UI state.
			
			var item:PlaylistItem = _player.playlist.getItemAt(0);
			item.file = files['default']['file'];
			
            //if(_config.state != true) { _config.state = false; }
     //       _redraw();
		}
		
		protected function onMouseHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			_list.visible = (event.type===MouseEvent.MOUSE_OVER);
		}
		protected function onListClick(event:ViewEvent):void
		{
			// TODO Auto-generated method stub
			Logger.log(event.data['file'],"FILE");
			
			_icon.label = event.data['label'];
			
			_swap(event.data['file']);
		}
		
		
		
		private function parseConfig():void{
			
			
				
			for (var key:String in _config){
				
				Logger.log(key,'file');
				
				if(key.substr(0,6) === "files_"){
									
					files[key.substr(6)] = {label:key.substr(6),file:_config[key]};
						if(files['default']==undefined)
							files['default'] = files[key.substr(6)];
				}
			}
			
			
		}
		
		/*private function parseConfig(str:String):void{
			
			
			var xml:XML = new XML(str);
			
			//			xml.parseString(str);
			
			Logger.log(xml,"xml");
			
			for each(var item:XML in xml.file){
				
				Logger.log(item.@src.toString(),'file');
				files[item.@label.toString()] = {label:item.@label.toString(),file:item.@src.toString()};
				if(files['default']==undefined)
					files['default'] = files[item.@label.toString()];
			}
			
			
		}*/
		

        /** Updates the button for availability of item. **/
/*        private function _itemHandler(event:PlaylistEvent):void {
            if(_reset > -1) {
                _player.playlist.getItemAt(_reset).start = 0;
                _reset = -1;
            }
            var item:PlaylistItem = _player.playlist.getItemAt(_player.playlist.currentIndex);
            if(item['hd.file'] && !item['ova.hidden']) {
                _isset = true;
            } else {
                _isset = false;
            }
   //         _redraw();
        };


        /** Updates the playlist with either the HD or original video. **/
/*        private function _playlistHandler(event:PlaylistEvent):void {
            // Reset the reset.
            _reset = -1;
            // Which item should we apply the global 'hd.file' to?
            // We should skip ova.hidden items.
            var firstVisible:Number = 0;
            // Store all the original files into the playlist.
            for(var i:Number = 0; i < _player.playlist.length; i++) {
                var item:PlaylistItem = _player.playlist.getItemAt(i);
                if (item['ova.hidden']) {
                    // This item is hidden by OVA; we shouldn't set its hd.file property. 
                    firstVisible++;
                }
                // Set the hd.file flashvar to the first playlistitem.
                if(i == firstVisible && _config.file) {
                    item['hd.file'] = _config.file;
                }
                if(item.provider == 'youtube') {
                    item['youtube.quality'] = 'medium';
                } else {
                    item['hd.original'] = item.file;
                }
            }
            // Do the HD swap if applicable.
            if(_config.state) {
                _swap();
            }
        };


        /** Check metadata for youtube quality levels. **/
        /*private function _metaHandler(event:MediaEvent):void { 
            if(event.metadata.youtubequalitylevels && 
                event.metadata.youtubequalitylevels.indexOf('hd720') > -1) { 
                _isset = true;
 //               _redraw();
            }
        };


        /** Set the HD button state. **/
     /*   private function _redraw():void {
            if(!_player.playlist.length || !_isset) {
                if (_button) {
                    _button.visible = false;
                } else { 
                    _icon.alpha = 0.1;
                }
            } else if (!_config.state) {
                if (_button) {
                    _button.field.text = 'is off';
                    _button.visible = true;
                } else {
                    _icon.alpha = 0.3;
                }
            } else {
                if (_button) {
                    _button.visible = true;
                    _button.field.text = 'is on';
                } else {
                    _icon.alpha = 1;
                }
            }
        };
		*/

        /** Enable HD if the fullscreen option is set. **/
        public function resize(width:Number, height:Number):void {
			_list.x = _player.controls.controlbar.getButton("hd").x;
            
			/*if(_isset && _config.fullscreen && _player.config.fullscreen && !_config.state) {
                _config.state = true;
                _swap();
            }*/
        };


        /** Switch the currently playing file with a new one. **/
        private function _swap(_file:String):void {
            // Swap HD state in every playlist item.
            // Restart player if not IDLE.
			var item:PlaylistItem = _player.playlist.getItemAt(0);
			
			item.file = _file;

			
            if(_player.state != PlayerState.IDLE) {
               // item.start = _position;
                _player.stop();
				Logger.log(_player.playlist.currentItem.start,"Pos before");

				_player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE,onLoaded);
				_player.play();

			}
          //  _redraw();
		}
		private function onLoaded(event:PlayerStateEvent):void
		{
			Logger.log(event.type,"event");
			
			
			if(event.newstate === PlayerState.PLAYING){
			// TODO Auto Generated method stub
				Logger.log(_position,"Pos after");
				var flag = _player.seek(_position);
				Logger.log(flag,"seek flag");
				_player.removeEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE,onLoaded);
			}
		}
		


        /** Save the position inside a video. **/
        private function _timeHandler(event:MediaEvent):void {
            _position = event.position;
        };


    }


}