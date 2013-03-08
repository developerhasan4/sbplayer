package
{
	import com.longtailvideo.jwplayer.events.*;
	import com.longtailvideo.jwplayer.player.*;
	import com.longtailvideo.jwplayer.plugins.*;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.view.components.*;
	
	import flash.display.*;
	import flash.errors.IllegalOperationError;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.*;
	

	public class RussiaSport extends Sprite implements IPlugin 
	{
			
		private var _player:IPlayer;
		private var _config:PluginConfig;
		
		private var _timeThumb:Sprite;
		private var _timeSlider:DisplayObject;
		
		private var _volumeThumb:Sprite;
		private var _volumeSlider:DisplayObject;
		
		private var _logoButton:DisplayObject;
		private var _tooltip:DisplayObject;
		
		private var d_txt:TextField;
		
		/** Let the player know what the name of your plugin is. **/
		public function get id():String 
		{
			return "RussiaSport"; 
		}
		
		/** Constructor **/
		public function RussiaSport() 
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
				
				//addPlusOneIcon();
				
				addTimeThumb();
				addVolumeThumb();
				addTimeDivider();
				addLogoIcon();
				
				//				
			}
		}
		
		private function addTimeDivider():void
		{
			// TODO Auto Generated method stub
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0x9a9a9a;
			textFormat.size = 11;
			textFormat.font = "_sans";
			
			
			d_txt = new TextField();
			d_txt.defaultTextFormat = textFormat;
			d_txt.selectable = false;
			d_txt.width = 0;
			d_txt.autoSize = TextFieldAutoSize.LEFT;
			d_txt.text = "//";
		
			d_txt.y = (27 - d_txt.height)/2;	
			
			DisplayObjectContainer(_player.controls.controlbar).addChild(d_txt);
			//					
		}		
		
		/**
		 * Logo implementation
		*/
		
		
		private function addLogoIcon(){
			
			if(_player.skin.getSkinElement(this.id, "icon")){
				_logoButton  = _player.skin.getSkinElement(this.id, "icon");
				
				_player.controls.controlbar.addButton(_logoButton, "rs-logo", onSportClick);
				
				_logoButton = _player.controls.controlbar.getButton("rs-logo");
				
				_logoButton.addEventListener(MouseEvent.MOUSE_OVER,onLogoOver);
				_logoButton.addEventListener(MouseEvent.MOUSE_OUT,onLogoOut);

				
				if(_player.skin.getSkinElement(this.id, "tooltip")){
					_tooltip  = _player.skin.getSkinElement(this.id, "tooltip");
					//_tooltip.y = _logoButton.y - _tooltip.height + 4;
					//_tooltip.x = _logoButton.x - 45;
					_tooltip.visible = false;
					_tooltip.addEventListener(MouseEvent.MOUSE_OVER,onLogoOver);
					_tooltip.addEventListener(MouseEvent.MOUSE_OUT,onLogoOut);
					_tooltip.addEventListener(MouseEvent.CLICK,onSportClick);
					DisplayObjectContainer(_player.controls.controlbar).addChild(_tooltip);
//					_player.addEventListener(ViewEvent.JWPLAYER_RESIZE,resizeHandler);
				}
			
			}
			
		}
		
		protected function onLogoOut(event:Event):void
		{
			// TODO Auto-generated method stub
			_tooltip.visible = false;			
		}
		
		protected function onLogoOver(event:Event):void
		{
			// TODO Auto-generated method stub
			DisplayObjectContainer(_player.controls.controlbar).setChildIndex(_tooltip,DisplayObjectContainer(_player.controls.controlbar).numChildren-1);
			
			_tooltip.visible = true;
		}		
		
		
		private function onSportClick(event:MouseEvent):void
		{
			if(_config['link'])
				navigateToURL(new URLRequest(_config['link']));
		}		
		
		
		/**
		 * Plus One implementation
		 * 
		 */
		
		private function addPlusOneIcon(){
			
			if(_player.skin.getSkinElement(this.id, "plusoneButton")){
				var _button:DisplayObject  = _player.skin.getSkinElement(this.id, "plusoneButton");
			
				_player.controls.controlbar.addButton(_button, "rs-plusone", null);
			}	
			
		}
		
		/**
		 * Time Thumb Implementation
		 */
		
		
		private function addTimeThumb(){
			
			if(_player.skin.getSkinElement(this.id, "timeSliderThumb")){
				_timeThumb = new Sprite();
				_timeThumb.mouseEnabled = _timeThumb.mouseChildren = false;
				
				var bgSkin:DisplayObject =  _player.skin.getSkinElement(this.id, "timeSliderThumb");
				_timeThumb.addChild(bgSkin);
				
				var time_doc = _player.controls.controlbar.getButton("time") as DisplayObjectContainer;
				_timeSlider = time_doc.getChildByName("clickarea") as DisplayObject;
				
				_timeSlider.addEventListener(MouseEvent.MOUSE_OVER, onMouseTimeHandler,false,0,true);
				_timeSlider.addEventListener(MouseEvent.MOUSE_OUT, onMouseTimeHandler,false,0,true);
				_timeSlider.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveTimeHandler);
				
				_timeThumb.visible = false;
				
				DisplayObjectContainer(_player.controls.controlbar).addChild(_timeThumb);
				
				
			}	
			
		}
		
		private function onMouseMoveTimeHandler(event:MouseEvent):void 
		{
				var pos:Number = event.localX;
				var percent:Number = pos / _timeSlider.width;
				
				var global_pt:Point = _timeSlider.localToGlobal(new Point(event.localX, event.localY));
				var local_pt:Point = _timeThumb.parent.globalToLocal(global_pt);
				_timeThumb.x = local_pt.x;
				_timeThumb.y = _timeSlider.y-_timeSlider.height;	
		}

		
		private function onMouseTimeHandler(event:MouseEvent):void 
		{
			
			var time_doc:DisplayObjectContainer = _player.controls.controlbar.getButton("time") as DisplayObjectContainer;
			var buffer:DisplayObject = time_doc.getChildByName("buffer");
			Logger.log(buffer.width,"buffer");
			Logger.log(event.localX,"event");
			
			_timeThumb.visible = (MouseEvent.MOUSE_OVER === event.type && buffer.width>event.localX && _player.state!=PlayerState.IDLE);
		}
	
		
		/**
		 * Volume Thumb implementation
		*/
		
		
		private function addVolumeThumb(){
			
			if(_player.skin.getSkinElement(this.id, "volumeSliderThumb")){
				_volumeThumb = new Sprite();
				_volumeThumb.mouseEnabled = _volumeThumb.mouseChildren = false;
				
				var bgSkin:DisplayObject =  _player.skin.getSkinElement(this.id, "volumeSliderThumb");
				_volumeThumb.addChild(bgSkin);
				
				var volume_doc = _player.controls.controlbar.getButton("volume") as DisplayObjectContainer;
				_volumeSlider = volume_doc.getChildByName("clickarea") as DisplayObject;
				
				_volumeSlider.addEventListener(MouseEvent.MOUSE_OVER, onMouseVolumeHandler,false,0,true);
				_volumeSlider.addEventListener(MouseEvent.MOUSE_OUT, onMouseVolumeHandler,false,0,true);
				_volumeSlider.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveVolumeHandler);
				
				_volumeThumb.visible = false;
				
				DisplayObjectContainer(_player.controls.controlbar).addChild(_volumeThumb);
				
				
			}	
			
		}
		
		private function onMouseMoveVolumeHandler(event:MouseEvent):void 
		{
			var pos:Number = event.localX;
			var percent:Number = pos / _volumeSlider.width;
			
			var global_pt:Point = _volumeSlider.localToGlobal(new Point(event.localX, event.localY));
			var local_pt:Point = _volumeThumb.parent.globalToLocal(global_pt);
			_volumeThumb.x = local_pt.x;
			_volumeThumb.y = _volumeSlider.y;// - _volumeSlider.height;	
		}
		
		
		private function onMouseVolumeHandler(event:MouseEvent):void 
		{
			
			_volumeThumb.visible = (MouseEvent.MOUSE_OVER === event.type);
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
		//	_timeSlider.y = -100;
			_tooltip.y = _logoButton.y - _tooltip.height + 4;
			_tooltip.x = _logoButton.x - 45;
			
			
			var el = _player.controls.controlbar.getButton("elapsed");
			
			Logger.log(d_txt.width,"rs-width");
			d_txt.x = el.x+el.width+d_txt.width/2 - 5;
			
			
		}
		
		private function resizeHandler(event:ViewEvent):void
		{
			// TODO Auto Generated method stub
			_tooltip.y = _logoButton.y - _tooltip.height + 2;
			_tooltip.x = _logoButton.x - 48;
			
		}		

		
	}
}
