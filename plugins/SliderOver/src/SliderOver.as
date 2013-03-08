package
{
	import com.jeroenwijering.events.PlayerEvent;
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
	import flash.text.*;
	

	public class SliderOver extends Sprite implements IPlugin 
	{
			
		private var _player:IPlayer;
		private var _config:PluginConfig;
		private var _button:MovieClip;
		private var _txt:TextField;
	
		/** Let the player know what the name of your plugin is. **/
		public function get id():String 
		{
			return "SliderOver"; 
		}
		
		/** Constructor **/
		public function SliderOver() 
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
				_button = new MovieClip();
				_txt = new TextField();
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.size = 11;
				textFormat.font = "_sans";
				textFormat.color = 0XFF0000;//0x9a9a9a;
				
				_txt.text = "//";
				_txt.setTextFormat(textFormat);
				_button.addChild(_txt);
				_button.width = 20;
				_button.height = 20;
				Logger.log("add icon",this.id);
				
				var res = _player.controls.controlbar.addButton(_button, 'SliderOver', null);
				
				Logger.log(res,this.id);
				
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
		//	_timeSlider.y = -100;
		}
		
		
	}
}
