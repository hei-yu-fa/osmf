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
package org.openvideoplayer.proxies
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import org.openvideoplayer.media.MediaElement;
	import org.openvideoplayer.media.TestMediaElement;
	import org.openvideoplayer.traits.ITemporal;
	import org.openvideoplayer.traits.MediaTraitType;
	import org.openvideoplayer.traits.PausableTrait;
	import org.openvideoplayer.traits.PlayableTrait;
	import org.openvideoplayer.traits.SeekableTrait;
	import org.openvideoplayer.traits.TemporalTrait;

	public class TestTemporalProxyElement extends TestMediaElement
	{
		public function TestTemporalProxyElement()
		{
			super();
		}
		
		public function testConstructor():void
		{
			try 
			{
				new TemporalProxyElement();
				new TemporalProxyElement(NaN);
				new TemporalProxyElement(NaN, new MediaElement());
			}
			catch(error:IllegalOperationError)
			{
				fail();
			}
		}
		
		override public function testInitialize():void
		{
			var temporalProxyElement:TemporalProxyElement = new TemporalProxyElement();
			
			var temporal:ITemporal = temporalProxyElement.getTrait(MediaTraitType.TEMPORAL) as ITemporal;
			assertTrue(temporal != null);
			assertTrue(temporal.duration == 0);
			
			temporalProxyElement.initialize([33]);
			
			assertTrue(temporal.duration == 33);
			
			// Try some invalid init params.
			//
			
			temporalProxyElement = new TemporalProxyElement();
			
			// Too few params.
			try
			{
				temporalProxyElement.initialize([]);
				
				fail();
			}
			catch (error:ArgumentError)
			{
			}

			temporalProxyElement = new TemporalProxyElement();
			
			// Too many params.
			try
			{
				temporalProxyElement.initialize([33, 33]);
				
				fail();
			}
			catch (error:ArgumentError)
			{
			}
			
			// If the param type is invalid, it's not strictly a failure
			// since we can generally coerce the value to a "null" equivalent
			// (e.g. zero).
			temporalProxyElement.initialize([new String()]);
			temporal = temporalProxyElement.getTrait(MediaTraitType.TEMPORAL) as ITemporal;
			assertTrue(temporal.duration == 0);
		}
		
		public function testTraits():void
		{
			var mediaElement:MediaElement = new MediaElement();
			var proxy:TemporalProxyElement = new TemporalProxyElement(NaN, mediaElement);
			
			assertTrue(mediaElement.getTrait(MediaTraitType.TEMPORAL) == null);
			assertTrue(proxy.getTrait(MediaTraitType.TEMPORAL) != null);
			
			assertTrue(mediaElement.getTrait(MediaTraitType.PAUSABLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.PAUSABLE) != null);
			
			assertTrue(mediaElement.getTrait(MediaTraitType.PLAYABLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.PLAYABLE) != null);
			
			assertTrue(mediaElement.getTrait(MediaTraitType.SEEKABLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.SEEKABLE) != null);
			
			assertTrue(proxy.getTrait(MediaTraitType.AUDIBLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.BUFFERABLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.LOADABLE) == null);
			assertTrue(proxy.getTrait(MediaTraitType.SPATIAL) == null);
			assertTrue(proxy.getTrait(MediaTraitType.VIEWABLE) == null);
		}
		
		public function testEvents():void
		{
			events = new Vector.<Event>();
			var mediaElement:MediaElement = new MediaElement();
			var proxy:TemporalProxyElement = new TemporalProxyElement(NaN, mediaElement);
			
			var temporal:TemporalTrait = proxy.getTrait(MediaTraitType.TEMPORAL) as TemporalTrait;
			var pausable:PausableTrait = proxy.getTrait(MediaTraitType.PAUSABLE) as PausableTrait;
			var playable:PlayableTrait = proxy.getTrait(MediaTraitType.PLAYABLE) as PlayableTrait;
			var seekable:SeekableTrait = proxy.getTrait(MediaTraitType.SEEKABLE) as SeekableTrait;
			
			playable.play();
			assertTrue(pausable.paused == false);
			pausable.pause();
			assertTrue(playable.playing == false);
			playable.play();
			assertTrue(pausable.paused == false);
		}
		
		public function eventCatcher(event:Event):void
		{
			events.push(event);
		}
		
		private var events:Vector.<Event>;
	}
}