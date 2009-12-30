/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.dynamicstreaming
{
	import flash.errors.*;
	import flash.events.*;
	import flash.net.NetStreamPlayOptions;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.events.*;
	import org.osmf.media.*;
	import org.osmf.net.*;
	import org.osmf.netmocker.*;
	import org.osmf.traits.*;
	import org.osmf.utils.*;
	import org.osmf.video.*;

	public class TestDynamicNetStream extends TestCase
	{
		override public function setUp():void
		{
			super.setUp();
			
			_testUnload = false;
			_startInManualMode = false;
			_callPlay2 = false;
			_testPlayFailed = false;
			_testSeek = false;
			_eventDispatcher = new EventDispatcher();
			_netFactory = new DynamicNetFactory();
			_loader = _netFactory.createNetLoader();
			
			if (_loader is MockDynamicStreamingNetLoader)
			{
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedEvents = [ 	new EventInfo(NetStreamCodes.NETSTREAM_BUFFER_EMPTY, "status", 9),
																						new EventInfo(NetStreamCodes.NETSTREAM_BUFFER_FULL, "status", 13) ];
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedDuration = 2;
			}
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			_loader = null;
			_netFactory = null;
			_eventDispatcher = null;
		}
		
		public function testDynamicNetStream():void
		{
			createDynamicStreamingElement();
		}
		
		public function testUnload():void
		{
			_testUnload = true;
			createDynamicStreamingElement();
		}
		
		public function testStartingOutInManualMode():void
		{
			_startInManualMode = true;
			createDynamicStreamingElement();
		}
		
		public function testPlay2():void
		{
			_callPlay2 = true;
			createDynamicStreamingElement();
		}
		
		public function testPlayFailed():void
		{
			_testPlayFailed = true;
			if (_loader is MockDynamicStreamingNetLoader)
			{
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedEvents = [ 	new EventInfo(NetStreamCodes.NETSTREAM_PLAY_FAILED, "status", 3) ];
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedDuration = 1;
			}
			
			createDynamicStreamingElement();						
		}
		
		public function testSeek():void
		{
			_testSeek = true;
			if (_loader is MockDynamicStreamingNetLoader)
			{
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedEvents = [ 	new EventInfo(NetStreamCodes.NETSTREAM_SEEK_NOTIFY, "status", 3) ];
				(_loader as MockDynamicStreamingNetLoader).netStreamExpectedDuration = 1;
			}
			
			createDynamicStreamingElement();									
		}
				
		private function createDynamicStreamingElement():void
		{	
			_dsr = new DynamicStreamingResource(new FMSURL(TestConstants.REMOTE_DYNAMIC_STREAMING_VIDEO_HOST));
			for each (var item:Object in TestConstants.REMOTE_DYNAMIC_STREAMING_VIDEO_STREAMS)
			{
				_dsr.streamItems.push(new DynamicStreamingItem(item["stream"], item["bitrate"]));
			}

			_dsr.initialIndex = 1;
			
			_mediaElement = new VideoElement(_loader, _dsr);
			_mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			
			_loadTrait = _mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
			_loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			
			_eventDispatcher.addEventListener("testComplete", addAsync(mustReceiveEvent, ASYNC_DELAY));
			
			_loadTrait.load();
		}
		
		private function onMediaError(e:MediaErrorEvent):void
		{
			if (!_testPlayFailed)
			{
				fail("Media error: " + e.error.message);
			}
		}
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			switch (event.loadState)
			{
				case LoadState.READY:
					var netLoadedContext:NetLoadedContext = _loadTrait.loadedContext as NetLoadedContext;
					netLoadedContext.stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
					netLoadedContext.stream.client.addHandler(NetStreamCodes.ON_PLAY_STATUS, onPlayStatus);
					
					_dsTrait = _mediaElement.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
					_dsTrait.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
					if (_startInManualMode)
					{
						_dsTrait.autoSwitch = false;
					}
					
					_playTrait = _mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
					
					try
					{
						if (_testUnload)
						{
							assertNotNull(_loadTrait);
							_loadTrait.unload();	
						}
						else if (_callPlay2)
						{
							netLoadedContext.stream.play2(new NetStreamPlayOptions());
						}
						else
						{
							_playTrait.play();
						}
					}
					catch (error:IllegalOperationError)
					{
						assertTrue(_callPlay2);
						_eventDispatcher.dispatchEvent(new Event("testComplete"));					
					}
					catch(e:Error)
					{
						fail(e.toString());
					}
					break;					
				case LoadState.LOAD_ERROR:
					fail("Load ERROR");
					break;
				case LoadState.UNLOADING:
					_eventDispatcher.dispatchEvent(new Event("testComplete"));
					break;				
			}
		}
		
		private function onPlayStatus(event:Object):void
		{
			if (event["code"] == NetStreamCodes.NETSTREAM_PLAY_COMPLETE)
			{
				_eventDispatcher.dispatchEvent(new Event("testComplete"));
			}
		}
		
		private function onNetStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
					if (!this._testPlayFailed)
					{
						fail("Play FAILED");
					}
					break;
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
					break;
			}	
		}
		
		private function onSwitchingChange(event:DynamicStreamEvent):void
		{
			var msg:String = "Switching change "
			var showCurrentIndex:Boolean = false;
			
			if (event.switching)
			{
				msg += "REQUESTED";
			}
			else
			{
				msg += "COMPLETE";
				showCurrentIndex = true;
			}
			
			/*
			case SwitchEvent.SWITCHSTATE_FAILED:
				if (!this._testPlayFailed)
				{
					msg += "FAILED";
					fail(msg);
				}
				break;
			*/
			
			if (event.detail != null)
			{
				msg += ", " + event.detail.description + ". " + event.detail.moreInfo;
			}
		}
			
		private function mustReceiveEvent(event:Event):void
		{
			// Placeholder to ensure an event is received.
		}
		
		
		private static const ASYNC_DELAY:Number = 90000;

		private var _eventDispatcher:EventDispatcher;
		private var _netFactory:DynamicNetFactory;
		private var _loader:NetLoader;
		private var _dsTrait:DynamicStreamTrait;
		private var _playTrait:PlayTrait
		private var _mediaElement:VideoElement;
		private var _loadTrait:LoadTrait;
		private var _dsr:DynamicStreamingResource;
		private var _testUnload:Boolean;
		private var _startInManualMode:Boolean;
		private var _callPlay2:Boolean;
		private var _testPlayFailed:Boolean;
		private var _testSeek:Boolean;
	}
}
