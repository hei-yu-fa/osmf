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
package org.osmf.net.httpstreaming
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * Dispatched when the bootstrap information has been downloaded and parsed.
	 */
	[Event(name="notifyIndexReady", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	
	/**
	 * Dispatched when rates information becomes available. The rates usually becomes available
	 * when the bootstrap information has been parsed.
	 */
	[Event(name="notifyRates", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]

	/**
	 * Dispatched when total duration value becomes available. The total duration usually becomes available
	 * when the bootstrap information has been parsed.
	 */
	[Event(name="notifyTotalDuration", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]

	/**
	 * Dispatched when the index handler needs the index to be downloaded.
	 */
	[Event(name="requestLoadIndex", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]
	
	/**
	 * Dispatched when the index handler encounters an unrecoverable error, such as an invalid 
	 * bootstrap box or an empty server base url.
	 */
	[Event(name="notifyError", type="org.osmf.events.HTTPStreamingFileIndexHandlerEvent")]

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Base class for HTTP streaming index handlers.
	 * 
	 * An index handler is responsible for mapping a media playback time to the
	 * URL from which the corresponding media fragment can be retrieved.
	 */
	public class HTTPStreamingIndexHandlerBase extends EventDispatcher
	{
		/**
		 * Constructor.
		 */
		public function HTTPStreamingIndexHandlerBase()
		{
		}
		
		/**
		 * Initializes this index with information about the media to be played.
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param indexInfo The info object used to initialize the index.
		 */
		public function initialize(indexInfo:HTTPStreamingIndexInfoBase):void
		{	
			throw new IllegalOperationError("The initialize() method must be overridden by the derived class.");
		}
		
		/**
		 * Called when the index file has been loaded and is ready to be processed.
		 * 
		 * Subclasses must override to provide a specific implementation.  When the
		 * index file is processed, that implementation should dispatch the
		 * notifyIndexReady event.
		 * 
		 * @param data The data from the index file.
		 */
		public function processIndexData(data:*):void
		{
			throw new IllegalOperationError("The onIndexLoaded() method must be overridden by the derived class.");
		}
		
		/**
		 * Returns the HTTPStreamRequest which encapsulates the file for the given
		 * playback time and quality.  If no such file exists for the specified time
		 * or quality, then this method should return null. 
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param time The time for which to retrieve a request object.
		 * @param quality The quality of the requested stream.
		 */
		public function getFileForTime(time:Number, quality:int):HTTPStreamRequest
		{
			throw new IllegalOperationError("The getFileForTime() method must be overridden by the derived class.");
		}
		
		/**
		 * Returns the HTTPStreamRequest which encapsulates the file that follows the
		 * previously retrieved file.  If no next file exists, or if the specified
		 * quality is out of range, then this method should return null. 
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param quality The quality of the requested stream.
		 */	
		public function getNextFile(quality:int):HTTPStreamRequest
		{
			throw new IllegalOperationError("The getNextFile() method must be overridden by the derived class.");
		}				
	}
}