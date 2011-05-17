/*****************************************************
 *  
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.media
{
	import flash.utils.Timer;
	
	import org.flexunit.asserts.fail;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class TestMediaPlayerHelper
	{		
		[Before]
		public function setUp():void
		{
			mediaPlayer = createMediaPlayer();
			mediaPlayerExpectedStates = new Vector.<String>();
			mediaPlayerRecordedStatesCount = 0;
		}
		
		[After]
		public function tearDown():void
		{
			if (mediaPlayer != null && mediaPlayer.canPlay)
			{
				mediaPlayer.stop();
			}
			
			if (mediaElement != null && mediaElement.hasTrait(MediaTraitType.LOAD))
			{
				(mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait).unload();
			}
			
			mediaElement = null;
			mediaPlayer = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		/// Protected event handlers
		
		/**
		 * @private
		 * 
		 * We fail the test and provide the error message.
		 */
		protected function onError(event:MediaErrorEvent):void
		{
			fail("MediaErrorEvent received. Error (" + event.error.errorID + ") with message (" + event.error.detail + ")");
		}
		
		/**
		 * @private
		 * 
		 * We fail the test on timeout.
		 */
		protected function onTimeout( passThroughData:Object):void
		{
			if (passThroughData != null)
			{
				fail("Expected event <" + passThroughData["expectedEvent"] + "> of type <" + passThroughData["expectedEventType"] + "> was not received.");
			}
			else
			{
				fail("Expected event was not received.");	
			}
		}
		
		/// Protected methods
		/**
		 * @private
		 * 
		 * Creates a media factory object to be used when tests need to 
		 * create media elements. Subclasses can override this method to 
		 * provide their own classes.
		 */
		protected function createMediaFactory():MediaFactory
		{
			return new DefaultMediaFactory();
		}
		
		/**
		 * @private
		 * 
		 * Creates a media player object to be used when tests need to
		 * control the playback of media elements. Subclasses can override 
		 * this method to provide their oen classes.
		 */
		protected function createMediaPlayer():MediaPlayer
		{
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			mediaPlayer.autoPlay = false;
			mediaPlayer.muted = true;
			mediaPlayer.autoDynamicStreamSwitch = false;
			mediaPlayer.loop = false;
			
			return mediaPlayer;
		}
		
		/**
		 * @private
		 * 
		 * Creates a media element object to be used when tests need to 
		 * create video elements. Subclasses can override this method to 
		 * provide their own classes.
		 */
		protected function createMediaElement(resource:MediaResourceBase):MediaElement
		{
			var factory:MediaFactory = createMediaFactory();
			if (factory == null)
				return null;
			
			return factory.createMediaElement(resource);
		}
		
		/// Internals
		protected var mediaElement:MediaElement = null;
		protected var mediaPlayer:MediaPlayer = null;
		protected var mediaPlayerExpectedStates:Vector.<String> = null;
		protected var mediaPlayerRecordedStatesCount:uint = 0;
	}
}