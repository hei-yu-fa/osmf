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

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * This is the bootstrap information data structure.
	 */	
	internal class AdobeBootstrapBox extends FullBox
	{
		/**
		 * Constructor.
		 */
		public function AdobeBootstrapBox()
		{
			super();
		}

		/**
		 * Indicates the version number of the bootstrap information. When the
		 * update field is set, this indicates the version number that is being
		 * updated. 
		 */
		public function get bootstrapVersion():uint
		{
			return _bootstrapVersion;
		}

		public function set bootstrapVersion(value:uint):void
		{
			_bootstrapVersion = value;
		}

		/**
		 * Indicates if it is the Named Access (0) or the Range Access (1) Profile. One bit reserved 
		 * for future profiles. 
		 */
		public function get profile():uint
		{
			return _profile;
		}

		public function set profile(value:uint):void
		{
			_profile = value;
		}
		
		/**
		 * Indicates if the media presentation is live (1) or not. 
		 */
		public function get live():Boolean
		{
			return _live;
		}
		
		public function set live(value:Boolean):void
		{
			_live = value;
		}

		/**
		 * Indicates if this table is an update (1) to a previously defined (sent) version of the 
		 * bootstrap box (or file). Updates are not complete replacement and MAY contain only the 
		 * changed elements and are sent only when there are changes to the bootstrap information. 
		 */
		public function get update():Boolean
		{
			return _update;
		}
		
		public function set update(value:Boolean):void
		{
			_update = value;
		}
		
		/**
		 * The number of time units in one second which the currentMediaTime and smpteTimeCodeOffset
		 * use to represent time. By default, 1000 is for milliseconds.
		 */
		public function get timeScale():uint
		{
			return _timeScale;
		}
		
		public function set timeScale(value:uint):void
		{
			_timeScale = value;
		}

		/**
		 * Indicates the timestamp of the latest available Fragment in the media presentation 
		 * represented in timescale units (default is milliseconds for the live scenario. 
		 * This is used by the client to request the right fragment number - it MAY be set to the total 
		 * duration or 0 for non-live cases. 
		 */
		public function get currentMediaTime():Number
		{
			return _currentMediaTime;
		}
		
		public function set currentMediaTime(value:Number):void
		{
			_currentMediaTime = value;
		}

		/**
		 * The offset of the media time from the SMPTE time code converted to milliseconds. 
		 * This field could be set to zero when not used. The SMPTE time code modulo 24 hours is used to 
		 * make the offset positive. 
		 */
		public function get smpteTimeCodeOffset():Number
		{
			return _smpteTimeCodeOffset;
		}

		public function set smpteTimeCodeOffset(value:Number):void
		{
			_smpteTimeCodeOffset = value;
		}
		
		/**
		 * The identifier of this presentation in the form of a NULL terminated string. 
		 * This could be a file or pathname in a URL.
		 */
		public function get movieIdentifier():String
		{
			return _movieIdentifier;
		}
		
		public function set movieIdentifier(value:String):void
		{
			_movieIdentifier = value;
		}

		/**
		 * The list of server base URLs.
		 */
		public function get serverBaseURLs():Vector.<String>
		{
			return _serverBaseURLs;
		}

		public function set serverBaseURLs(value:Vector.<String>):void
		{
			_serverBaseURLs = value;
		}

		/**
		 * The list of quality segment URL modifiers.
		 */
		public function get qualitySegmentURLModifiers():Vector.<String>
		{
			return _qualitySegmentURLModifiers;
		}

		public function set qualitySegmentURLModifiers(value:Vector.<String>):void
		{
			_qualitySegmentURLModifiers = value;
		}
		
		/**
		 * DRM metadata required for encrypted files to obtain the necessary keys/license 
		 * for decryption and playback..
		 */
		public function get drmData():String
		{
			return _drmData;
		}
		
		public function set drmData(value:String):void
		{
			_drmData = value;
		}

		/**
		 * Metadata.
		 */
		public function get metadata():String
		{
			return _metadata;
		}
		
		public function set metadata(value:String):void
		{
			_metadata = value;
		}

		/**
		 * The list of segment run tables. Normally there should be only one. 
		 */
		public function get segmentRunTables():Vector.<AdobeSegmentRunTable>
		{
			return _segmentRunTables;
		}

		public function set segmentRunTables(value:Vector.<AdobeSegmentRunTable>):void
		{
			_segmentRunTables = value;
		}
		
		/**
		 * The list of fragment run tables. Normally there should be only one.
		 */
		public function get fragmentRunTables():Vector.<AdobeFragmentRunTable>
		{
			return _fragmentRunTables;
		}

		public function set fragmentRunTables(value:Vector.<AdobeFragmentRunTable>):void
		{
			_fragmentRunTables = value;
		}

		/**
		 * Given a fragment number, returns the corresponding Id of the segment
		 * that contains the fragment.
		 * 
		 * @param fragmentId The Id of the fragment whose containing segment to be found.
		 * 
		 * @return the Id of the segment that contains the segment.
		 */
		public function findSegmentId(fragmentId:uint):uint
		{
			return _segmentRunTables[0].findSegmentIdByFragmentId(fragmentId);
		}		
		
		/**
		 * The total number of fragments in the movie.
		 */
		public function get totalFragments():uint
		{
			var afrt:AdobeFragmentRunTable = _fragmentRunTables[_fragmentRunTables.length - 1];
			var fdps:Vector.<FragmentDurationPair> = afrt.fragmentDurationPairs;
			return fdps[fdps.length - 1].firstFragment;
		}
		
		/**
		 * The total duration of the movie.
		 */
		public function get totalDuration():uint
		{
			return (_fragmentRunTables.length < 1) ? 0 : _fragmentRunTables[0].totalDuration;
		}

		// Internal
		//
		
		private var _bootstrapVersion:uint;
		private var _profile:uint;
		private var _live:Boolean;
		private var _update:Boolean;
		
		private var _timeScale:uint;
		private var _currentMediaTime:Number;
		private var _smpteTimeCodeOffset:Number;
		private var _movieIdentifier:String;
		private var _serverEntryCount:uint;
		private var _serverBaseURLs:Vector.<String>;
		private var _qualitySegmentURLModifiers:Vector.<String>;
		private var _drmData:String;
		private var _metadata:String;
		private var _segmentRunTables:Vector.<AdobeSegmentRunTable>;
		private var _fragmentRunTables:Vector.<AdobeFragmentRunTable>;
	}
}