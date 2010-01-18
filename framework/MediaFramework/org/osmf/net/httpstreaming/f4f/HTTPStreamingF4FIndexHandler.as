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
package org.osmf.net.httpstreaming.f4f
{
	import __AS3__.vec.Vector;
	
	import flash.net.URLRequest;
	
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;

	CONFIG::LOGGING 
	{	
		import org.osmf.logging.ILogger;
	}

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The actual implementation of HTTPStreamingFileIndexHandlerBase.  It
	 * handles the indexing scheme of an F4V file.
	 */	
	public class HTTPStreamingF4FIndexHandler extends HTTPStreamingIndexHandlerBase
	{
		/**
		 * Constructor.
		 */
		public function HTTPStreamingF4FIndexHandler()
		{
			super();
			
			currentQuality = -1;
		}
		
		/**
		 * @private
		 */
		override public function initialize(indexInfo:HTTPStreamingIndexInfoBase):void
		{
			// Make sure we have an info object of the expected type.
			var f4fIndexInfo:HTTPStreamingF4FIndexInfo = indexInfo as HTTPStreamingF4FIndexInfo;
			if (f4fIndexInfo == null)
			{
				throw new ArgumentError();
			}

			serverBaseURL = f4fIndexInfo.serverBaseURL;
			
			streamInfos = f4fIndexInfo.streamInfos;
			
			// If the bootstrapInfoData is null, we dispatch an event 
			// that contains the URL to the bootstrap information file
			// so that HTTPNetStream can retrieve it. 
			if (f4fIndexInfo.bootstrapInfoData == null)
			{
				dispatchEvent
					(	new HTTPStreamingIndexHandlerEvent
							( HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX 
							, false 
							, false 
							, null 
							, 0
							, new URLRequest(f4fIndexInfo.bootstrapInfoURL) 
							, true
							)
					);
			}
			else
			{
				processIndexData(f4fIndexInfo.bootstrapInfoData);
			}
		}
		
		/**
		 * @private
		 */
		override public function processIndexData(data:*):void
		{
			var parser:BoxParser = new BoxParser();
			parser.init(data);
			try
			{
				var boxes:Vector.<Box> = parser.getBoxes();
			}
			catch (e:Error)
			{
				boxes = null;
			}
			
			if (boxes == null || boxes.length < 1)
			{
				dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR)); 

				return;
			}
			
			abst = boxes[0] as AdobeBootstrapBox;
			if (abst == null)
			{
				dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));
				
				return;
			}
			
			currentFragmentNumber = 1;
			if (serverBaseURL == null || serverBaseURL.length <= 0)
			{
				if (abst.serverBaseURLs != null && abst.serverBaseURLs.length > 0)
				{
					// If serverBaseURL is not set from the external, we need to pick 
					// a server base URL from the bootstrap box. For now, we just
					// pick the first one.
					serverBaseURL = abst.serverBaseURLs[0];
				}
				else
				{
					dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));

					return;
				}
			}
			
			dispatchEvent
				( new HTTPStreamingIndexHandlerEvent
					( HTTPStreamingIndexHandlerEvent.NOTIFY_RATES
					, false
					, false
					, getQualityRates(streamInfos)
					)
				);
			
			dispatchEvent
				( new HTTPStreamingIndexHandlerEvent
					( HTTPStreamingIndexHandlerEvent.NOTIFY_TOTAL_DURATION
					, false
					, false
					, null
					, abst.totalDuration / abst.timeScale
					)
				);
			
			dispatchEvent
				( new HTTPStreamingIndexHandlerEvent
					( HTTPStreamingIndexHandlerEvent.NOTIFY_INDEX_READY
					)
				);
		}	
		
		/**
		 * @private
		 */
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest
		{
			var streamRequest:HTTPStreamRequest = null;
			
			var frt:AdobeFragmentRunTable = getFragmentRunTable();
			if (	time >= 0
				&&	time * abst.timeScale <= frt.totalDuration
				&& 	quality >= 0
				&&  quality < streamInfos.length
			   )
			{
				currentFragmentNumber = frt.findFragmentIdByTime(time * abst.timeScale);
				var segId:uint = abst.findSegmentId(currentFragmentNumber);
				
				var requestUrl:String = serverBaseURL + "/" + streamInfos[quality].streamName + "Seg" + segId + "-Frag" + currentFragmentNumber;
				currentFragmentNumber++;
				
				CONFIG::LOGGING
				{
					logger.debug("getFileForTime URL = " + requestUrl);
				}
			
				streamRequest = new HTTPStreamRequest(requestUrl);
				checkQuality(quality);
			}
			
			CONFIG::LOGGING
			{
				if (streamRequest == null)
				{
					logger.debug("getFileForTime No URL for time=" + time + " and quality=" + quality);
				}
			}
			
			return streamRequest;
		}
		
		/**
		 * @private
		 */
		override public function getNextFile(quality:int):HTTPStreamRequest
		{
			var streamRequest:HTTPStreamRequest = null;
			
			if (	currentFragmentNumber <= abst.totalFragments
				&& 	quality >= 0
				&&  quality < streamInfos.length
			   )
			{
				var segId:uint = abst.findSegmentId(currentFragmentNumber);
				var requestUrl:String = serverBaseURL + "/" + streamInfos[quality].streamName + "Seg" + segId + "-Frag" + currentFragmentNumber;
				currentFragmentNumber++;
				
				streamRequest = new HTTPStreamRequest(requestUrl);
				checkQuality(quality);
					
				CONFIG::LOGGING
				{
					logger.debug("getNextFile URL = " + requestUrl);
				}
			}
			
			CONFIG::LOGGING
			{
				if (streamRequest == null)
				{
					logger.debug("getNextFile No URL for quality=" + quality);
				}
			}
			
			return streamRequest;
		}
		
		/**
		 * @private
		 * 
		 * Given timeBias, calculates the corresponding segment duration.
		 */
		internal function calculateSegmentDuration(timeBias:Number):Number
		{
			var fragmentDurationPairs:Vector.<FragmentDurationPair> = (abst.fragmentRunTables)[0].fragmentDurationPairs;
			var fragmentId:uint = currentFragmentNumber - 1;
			
			var index:int =  fragmentDurationPairs.length - 1;
			while (index >= 0)
			{
				var fragmentDurationPair:FragmentDurationPair = fragmentDurationPairs[index];
				if (fragmentDurationPair.firstFragment <= fragmentId)
				{
					var duration:Number = fragmentDurationPair.duration;
					var durationAccrued:Number = fragmentDurationPair.durationAccrued;
					durationAccrued += (fragmentId - fragmentDurationPair.firstFragment) * fragmentDurationPair.duration;
					if (timeBias > 0)
					{
						duration -= (timeBias - durationAccrued);
					}
					
					return duration;
				}
				else
				{
					index--;
				}
			}
			
			return 0;
		}

		// Internal
		//
		
		/**
		 * When there is an MBR switching and the switched-to fragment is DRM protected,
		 * we need to append the additionalHeader that contains the DRM metadata to the Flash Player
		 * for that fragment before any additional TCMessage can be appended to FP.
		 */
		private function checkQuality(quality:int):void
		{
			if (currentQuality != quality)
			{
				currentQuality = quality;
				if (streamInfos[currentQuality].additionalHeader != null)
				{
					dispatchEvent
						( new HTTPStreamingIndexHandlerEvent
							( HTTPStreamingIndexHandlerEvent.NOTIFY_ADDITIONAL_HEADER
							, false
							, false
							, null
							, 0
							, null
							, true
							, streamInfos[currentQuality].additionalHeader
							)
						);
				}
			}
		}
		
		private function getQualityRates(streamInfos:Vector.<HTTPStreamingF4FStreamInfo>):Array
		{
			var rates:Array = [];
			
			if (streamInfos.length > 1)
			{
				for (var i:int = 0; i < streamInfos.length; i++)
				{
					var streamInfo:HTTPStreamingF4FStreamInfo = streamInfos[i] as HTTPStreamingF4FStreamInfo;
					rates.push(streamInfo.bitrate);
				}
			}
			
			return rates;
		}

		private function getFragmentRunTable():AdobeFragmentRunTable
		{
			// For now, we assume that there is only one fragment run table.
			return abst.fragmentRunTables[0];
		}

		private var abst:AdobeBootstrapBox;
		private var currentFragmentNumber:int;
		private var serverBaseURL:String;
		private var streamInfos:Vector.<HTTPStreamingF4FStreamInfo>;
		private var currentQuality:int;
		
		CONFIG::LOGGING
		{
			private static const logger:org.osmf.logging.ILogger = org.osmf.logging.Log.getLogger("org.osmf.net.httpstreaming.HTTPStreamF4FIndexHandler");
		}
	}
}