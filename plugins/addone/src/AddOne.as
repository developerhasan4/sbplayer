package
{
	import com.longtailvideo.jwplayer.events.*;
	import com.longtailvideo.jwplayer.player.*;
	import com.longtailvideo.jwplayer.plugins.*;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.view.components.*;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	


	public class AddOne extends Sprite implements IPlugin 
	{
			
		private var _player:IPlayer;
		private var _config:PluginConfig;
		
			
		private var _button:DisplayObject;
		private var _list:DropDownList;
		private var icons:Object;
		
		/** Let the player know what the name of your plugin is. **/
		public function get id():String 
		{
			return "addone"; 
		}
		
		/** Constructor **/
		public function AddOne() 
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
				
				addPlusOneIcon();
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
		
		private function addPlusOneIcon(){
			
			if(_player.skin.getSkinElement(this.id, "addoneButton")){
				var _but:DisplayObject  = _player.skin.getSkinElement(this.id, "addoneButton");
			
				_player.controls.controlbar.addButton(_but, "addone", onPlusOne);
				
				_button = _player.controls.controlbar.getButton("addone");
				
				_list = new DropDownList();
				_list.init(100,24,"a");
				
				if(_player.skin.getSkinElement(this.id, "rs")){
					Logger.log("rs","addone");					
					
				//	var _icon1 = _player.skin.getSkinElement(this.id, "rs");
					_list.addItem({label:"RussiaSport",icon:_player.skin.getSkinElement(this.id, "rs")});
					
				}

				if(_player.skin.getSkinElement(this.id, "fb")){
					Logger.log("fb","addone");					
					
					//var _icon2 = _player.skin.getSkinElement(this.id, "fb");
					_list.addItem({label:"Facebook",icon:_player.skin.getSkinElement(this.id, "fb")});
					
				}
				
				if(_player.skin.getSkinElement(this.id, "tw")){
					Logger.log("tw","addone");					
						
					//var _icon3 = _player.skin.getSkinElement(this.id, "tw");
					_list.addItem({label:"Twitter",icon:_player.skin.getSkinElement(this.id, "tw")});
					
				}
				
				if(_player.skin.getSkinElement(this.id, "vk")){
					Logger.log("vk","addone");					
					
					//var _icon4 = _player.skin.getSkinElement(this.id, "vk");
					_list.addItem({label:"ВКонтакте",icon:_player.skin.getSkinElement(this.id, "vk")});
					
				}
				
				_list.visible = false;
				DisplayObjectContainer(_player.controls.controlbar).addChild(_list as DisplayObject);
				
				_button.addEventListener(MouseEvent.MOUSE_OVER,onMouseHandler);
				_button.addEventListener(MouseEvent.MOUSE_OUT,onMouseHandler);

				_list.addEventListener(ViewEvent.JWPLAYER_VIEW_CLICK,onPlusOne);
				_list.addEventListener(MouseEvent.MOUSE_OVER,onMouseHandler);
				_list.addEventListener(MouseEvent.MOUSE_OUT,onMouseHandler);
				
			}	
			
		}
		
		protected function onMouseHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			_list.visible = (event.type===MouseEvent.MOUSE_OVER);
		}
		
		private function onPlusOne(event:ViewEvent):void
		{
			// TODO Auto Generated method stub
			
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
			
			_list.x = _button.x - (_list.width - _player.controls.controlbar.getButton("addone").width)/2;
			
		}
		

		
	}
}
