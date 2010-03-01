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
package org.osmf.syndication.media
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.syndication.model.Entry;
	
	public class SyndicationMediaGenerator
	{
		public function SyndicationMediaGenerator(mediaResolver:ISyndicationMediaResolver=null)
		{
			this.mediaResolver = mediaResolver;
			if (this.mediaResolver == null)
			{
				this.mediaResolver = new DefaultSyndicationMediaResolver();
			}
		}
		
		public function createMediaElement(entry:Entry, mediaFactory:MediaFactory=null):MediaElement
		{
			return mediaResolver.createMediaElement(entry, mediaFactory);
		}

		private var mediaResolver:ISyndicationMediaResolver;
		
	}
}