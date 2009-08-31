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
package org.openvideoplayer.image
{
	import org.openvideoplayer.content.TestContentLoaderIntegration;
	import org.openvideoplayer.media.IMediaResource;
	import org.openvideoplayer.media.URLResource;
	import org.openvideoplayer.utils.TestConstants;
	import org.openvideoplayer.utils.URL;
	
	public class TestImageLoaderIntegration extends TestContentLoaderIntegration
	{
		override protected function createInterfaceObject(... args):Object
		{
			return new ImageLoader();
		}
		
		override protected function get successfulResource():IMediaResource
		{
			return new URLResource(new URL(TestConstants.REMOTE_IMAGE_FILE));
		}

		override protected function get failedResource():IMediaResource
		{
			return new URLResource(new URL(TestConstants.REMOTE_INVALID_IMAGE_FILE));
		}
	}
}