package
{
import com.longtailvideo.jwplayer.events.*;
import com.longtailvideo.jwplayer.model.PlaylistItem;
import com.longtailvideo.jwplayer.player.*;
import com.longtailvideo.jwplayer.plugins.*;
import com.longtailvideo.jwplayer.utils.Animations;
import com.longtailvideo.jwplayer.utils.Draw;
import com.longtailvideo.jwplayer.utils.Logger;
import com.longtailvideo.jwplayer.utils.RootReference;
import com.longtailvideo.jwplayer.view.components.*;

import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class Header extends Sprite implements IPlugin
	{
			
		private var _player:IPlayer;
		private var _config:PluginConfig;
		
		private var animations:Animations;
			
		private var _button:MovieClip;
		private var _back:Sprite;
		
		private var share_btn:MovieClip;
		private var rel_btn:MovieClip;
		
		private var related:RelatedVideos;
		private var related_arr:Array;
		
		
		private var lastW:int;
		private var lastH:int;
		
		private var lastBH:int;
		
		private var share_field:MovieClip;
		
		private var author_txt:TextField;
		private var title_txt:TextField;
		
		private var _fadingOut:uint;

        private var _playlistItem:PlaylistItem;

		
		[Embed(source="../../../assets/copy.png")]
		private var CopyIcon:Class;
		
		
		public function get id():String 
		{
			return "header"; 
		}
		
		/** Constructor **/
		public function Header() 
		{
		}
		
		/**
		 * Called by the player after the plugin has been created.
		 *  
		 * @param player A reference to the player's API
		 * @param config The plugin's configuration parameters.
		 */
		public function initPlugin(player:IPlayer, config:PluginConfig):void 
		{
			_player = player;
			_config = config;
			
			if (_player.skin.hasComponent("controlbar"))
			{	// Recent skin
				
				addHeader();
					//				
			}
		}
		
		
		/**
		 * Logo implementation
		*/
		
		
		
		
		/**
		 * Plus One implementation
		 * 
		 */
		
		private function addHeader():void
        {
			
			Logger.log(Capabilities.screenResolutionY,"Resolution");
			
			var _item:PlaylistItem = _player.playlist.currentItem;
			
			_config['author'] = (_config['author']!=undefined) ? _config['author'] : _item['header.author'];
			_config['author_link'] = (_config['author_link']!=undefined) ? _config['author_link'] : _item['header.author_link'];
			_config['title'] = (_config['title']!=undefined) ? _config['title'] : _item['header.title'];
			_config['title_link'] = (_config['title_link']!=undefined) ? _config['title_link'] : _item['header.title_link'];
			
			Logger.log(_config['author'],'header');
			Logger.log(_config['title'],'header');
			Logger.log(_config['related'],'header');
			Logger.log(_config['share'],'header');
			
			
			
			if(_config['author']!=undefined && _config['title']!=undefined){
				
				_button = new MovieClip();
				_back = Draw.gradientRect(_button,[0x000000,0x000000],[1,0],[0,255],560,100,0,0);
				
				var _tf:TextFormat = new TextFormat();
				_tf.align = "left";
				_tf.color = "0xfa0000";
				_tf.font = "Arial";
				_tf.size = 11;
				_tf.underline = true;
				
				var _tf2:TextFormat = new TextFormat();
				_tf2.align = "left";
				_tf2.color = "0xffffff";
				_tf2.font = "Arial";
				_tf2.size = 18;
				_tf2.underline = true;
	
				
				
				title_txt = new TextField();
				title_txt.selectable = false;
				title_txt.defaultTextFormat = _tf2;
				title_txt.width = 450;
				
				title_txt.wordWrap = true;
				title_txt.multiline = true;
				title_txt.htmlText = '<a href="event:title">'+_config['title']+'</a>';
				title_txt.y = 47;
				title_txt.x = 18;
				title_txt.name = "title";
				title_txt.addEventListener(TextEvent.LINK,onClick);
					
				
				_button.addChild(title_txt);
				
				author_txt = new TextField();
				author_txt.selectable = false;
				author_txt.defaultTextFormat = _tf;
				author_txt.autoSize = TextFieldAutoSize.LEFT;
              //  author_txt.embedFonts = true;
                author_txt.antiAliasType = flash.text.AntiAliasType.ADVANCED;
				author_txt.htmlText = '<a href="event:author">'+_config['author']+'</a>';
				author_txt.y = 27;
				author_txt.x=18;
				author_txt.height = 20;
				author_txt.name = "author";
				author_txt.addEventListener(TextEvent.LINK,onClick);
				
				_button.addChild(author_txt);
				
				_player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE,onStateChanged);
				
				
				_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE,onCompleteMedia);
				
				if(_config['related']!=undefined){
				
					loadRelated(_config['related']);		
				
				}
				
				if(_config['share']!=undefined){
				
					if(Capabilities.screenResolutionY>2000)
						share_btn = new RSButtonIcon(_player.skin.getSkinElement(this.id, "share"));
					else
						share_btn = new RSButton("Поделиться");
					
					share_btn.y = 7;
					share_btn.addEventListener(MouseEvent.CLICK,onShareClick);
					_button.addChild(share_btn);
					
					share_field = new MovieClip();
					share_field.visible = false;
					//share_field.width = 548;
					//share_field.hteight = 127;
					share_field.x = 5;
					share_field.y = 35;
					
					var link_txt:TextField = new TextField();
					link_txt.x = 13;
					link_txt.y = 13;
					link_txt.selectable = true;
					link_txt.autoSize = TextFieldAutoSize.LEFT;
					//link_txt.mouseEnabled = false;
					
					var tf:TextFormat = new TextFormat();
					tf.color =0x999999;
					tf.font = "Arial";
					tf.kerning = true;
//					tf.letterSpacing = -0.7;
					tf.size = 12;
//					tf.bold = true;
					
					link_txt.defaultTextFormat = tf;
					link_txt.text = _config['share'];
					
					share_field.addChild(link_txt);
					
					var share_copy:MovieClip = new MovieClip();
					share_copy.addChild(new CopyIcon());
					share_copy.x = 525;
					share_copy.y = 15;
					share_copy.name = "share";
					share_copy.addEventListener(MouseEvent.CLICK,onShareFieldClick);
					share_field.addChild(share_copy);
					
					
					var embed_txt:TextField = new TextField();
					embed_txt.x = 13;
					embed_txt.y = 46;
					embed_txt.width = 506;
					embed_txt.wordWrap = true;
					embed_txt.multiline = true;
					embed_txt.selectable = true;
					embed_txt.autoSize = TextFieldAutoSize.LEFT;
					embed_txt.defaultTextFormat = tf;
					embed_txt.text = _config['embed'];
					
					share_field.addChild(embed_txt);
					
					
					var embed_copy:MovieClip = new MovieClip();
					embed_copy.addChild(new CopyIcon());
					embed_copy.x = 525;
					embed_copy.y = 65;
					embed_copy.name = "embed"; 
					embed_copy.addEventListener(MouseEvent.CLICK,onShareFieldClick);

					share_field.addChild(embed_copy);
					
					
					
					share_field.graphics.lineStyle(1,0x333333);
					share_field.graphics.beginFill(0x000000);
					share_field.graphics.drawRoundRect(0,0,548,127,3,3);
					share_field.graphics.endFill();
					
					share_field.graphics.lineStyle(1,0x333333);
					share_field.graphics.drawRoundRect(12,12,508,22,6,6);
					
					share_field.graphics.lineStyle(1,0x333333);
					share_field.graphics.drawRoundRect(12,45,508,72,6,6);

					share_field.addEventListener(MouseEvent.CLICK,onShareFieldClick);
					
					_button.addChild(share_field);
					
					if(_config['related'] == undefined)
						share_btn.x = 560 - 10 - share_btn.width;
				}
				
				
				
				
				
				DisplayObjectContainer(_player.controls.display).addChild(_button as DisplayObject);
				
				
				
				
				animations = new Animations(_button);
				
			}	
			
		}
		
		private function onCompleteMedia(e:MediaEvent):void
		{
			Logger.log("complete","Header_MEDIA");
            onRelClick();
		}
		
		protected function onShareClick(event:MouseEvent):void
		{
			if(share_field.visible){
				
				share_field.visible = false;
				_back.height = lastH * (100/340);
				author_txt.visible = true;
				title_txt.visible = true;
				
				if(_player.state === PlayerState.IDLE || _player.state === PlayerState.PAUSED)
					(_player.controls.display as DisplayComponent).showPlayIcon();
				
			}else{
				
				_back.height = lastH;
				author_txt.visible = false;
				title_txt.visible = false;
				share_field.visible = true;
				if(related)
					related.visible = false;

				(_player.controls.display as DisplayComponent).clearDisplay();
			}
			
			event.stopPropagation();
		}
		
		protected function onShareFieldClick(event:MouseEvent):void
		{
			
			Logger.log(event.target.name,"name");
			
			if(event.target.name === "share")
				System.setClipboard(_config['share']);
			
			if(event.target.name === "embed")
				System.setClipboard(_config['embed']);
			
			event.stopPropagation();
		}		
		
		private function loadRelated(src:String):void{
			
			
			Logger.log(src,"RELSOURCE");
			
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE,onComplete);
			
			loader.load(new URLRequest(src));
			
			
			
		}
		
		protected function onComplete(event:Event):void
		{

			var loader:URLLoader = event.target as URLLoader;
			
			Logger.log(loader.data,"Loader");
			
			if(loader.data){
				
				var _xml:XML = new XML(loader.data);
				
				related_arr = [];
				
				for each(var item:XML in _xml.item){
				
					related_arr.push({url:item..url,image:item..image,duration:item..duration,title:item..title});
								
				}
				
				if(related_arr.length>0)
					initRelated();
			}
			
		}		
		
		
		
		private function initRelated():void{
			if(Capabilities.screenResolutionY>2000)
				rel_btn = new RSButtonIcon(_player.skin.getSkinElement(this.id, "more"));
			else
				rel_btn = new RSButton("Еще видео");
			
			rel_btn.y = 7;
			rel_btn.addEventListener(MouseEvent.CLICK,onRelClick);
			_button.addChild(rel_btn);
			rel_btn.x = 560 - 10 - rel_btn.width;
			
			related = new RelatedVideos();
			
			related.init(related_arr);
			related.x = 20;
			related.y = 48;
			related.visible = false;
			
			_button.addChild(related);
			related.addEventListener(ViewEvent.JWPLAYER_VIEW_CLICK,onRelatedClick);
			
			if(_config['share'])
				share_btn.x = 560 - 10 - rel_btn.width - 10 - share_btn.width;

		}
		
		
		private function onRelClick(event:MouseEvent = null):void
		{

			if(related.visible){
				
				_back.height = lastH * (100/340);
				related.visible = false;
				author_txt.visible = true;
				title_txt.visible = true;
				
				if(_player.state === PlayerState.IDLE || _player.state === PlayerState.PAUSED)
					(_player.controls.display as DisplayComponent).showPlayIcon();
				
			}else{
				_back.height = lastH;
				author_txt.visible = false;
				title_txt.visible = false;
				if(share_field)
					share_field.visible = false;
				related.visible = true;
				(_player.controls.display as DisplayComponent).clearDisplay();
			}
			
			event.stopPropagation();
		//	startFader();
		}
		
		protected function onRelatedClick(event:ViewEvent):void
		{
			Logger.log(event.data,"related");
			if(event.data!="")
				navigateToURL(new URLRequest(event.data));
			//startFader();
		}
		
		protected function onMouseClick(event:MouseEvent):void
		{
			event.stopPropagation();
			event.target.removeEventListener(MouseEvent.CLICK,onMouseClick);
		}
		
		protected function onClick(event:TextEvent):void
		{
			Logger.log(event.target.name,'header');
			Logger.log(_config[event.target.name+'_link'],'header');
			event.target.addEventListener(MouseEvent.CLICK,onMouseClick);

			if(_config[event.target.name+'_link'])
				navigateToURL(new URLRequest(_config[event.target.name+'_link']));
			
			//startFader();
		}
		
		private function onStateChanged(event:PlayerStateEvent):void
		{

			if(event.newstate === PlayerState.IDLE || event.newstate === PlayerState.PAUSED){
				//_button.visible = true;
				RootReference.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				if (!isNaN(_fadingOut)) {
					clearTimeout(_fadingOut);
				}
				animations.ease(_button.x,0,2);
				/*if(event.newstate === PlayerState.IDLE && rel_btn){
                     if(_player.playlist.currentItem == _playlistItem){
                        Logger.log("show rel","IDLE");
                    }else{
                        Logger.log("switch","IDLE");
                    }
                } */
				//onRelClick();
			}else{
				//_button.visible = false;
				_playlistItem = _player.playlist.currentItem;
                startFader();
				RootReference.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			}
		}		
		
		
		
		private function onMouseMove(event:MouseEvent):void
		{
			if(_button.y!=0)
				animations.ease(_button.x,0,2);
			
		//	Logger.log(_button.y,'buton');
			
			startFader();
			
			
		}
		
		
		private function startFader():void {
			if (!isNaN(_fadingOut)) {
					clearTimeout(_fadingOut);
			}
			
			_fadingOut = setTimeout(moveTimeout, 2000);
			
		}
		
		
		
		
		private function moveTimeout(evt:Event=null):void {
							
				animations.ease(x,-_button.height,2);
			
		}
		
/*		protected function onMouseHandler(event:MouseEvent):void
		{
			_list.visible = (event.type===MouseEvent.MOUSE_OVER);
		}
		
		private function onPlusOne(event:ViewEvent):void
		{

			Logger.log(event.data['label'],'addone');

			
			if(ExternalInterface.available){
				
				
				Logger.log(ExternalInterface.call(event.data['label'],ExternalInterface.objectID),'addone');
				
				
			}
			
			
		}
		
		/**
		 * When the player resizes itself, it sets the x/y coordinates of all components and plugins.  
		 * Then it calls resize() on each plugin, which is then expected to lay itself out within 
		 * the requested boundaries.  Plugins whose position and size are not set by flashvar configuration
		 * receive the video display area's dimensions in resize().
		 *  
		 * @param width Width of the plugin's layout area, in pixels 
		 * @param height Height of the plugin's layout area, in pixels
		 */		
		public function resize(w:Number, h:Number):void 
		{
			var _scale:Number = w/_back.width;
			
			lastW = w;
			lastH = h;
			
//			_back.width = w;
			//_button.x - (_list.width - _player.controls.controlbar.getButton("addone").width)/2;
			
			_button.scaleX = _scale;
			_button.scaleY = _scale;
			
			
		/*	if(_config['related']!=undefined)
				rel_btn.x = w - 10 - rel_btn.width;//490;
			if(_config['share']!=undefined)
				share_btn.x = w - 10 - rel_btn.width - 10 - share_btn.width;//408;
			*/
		}
		

		
	}
}
