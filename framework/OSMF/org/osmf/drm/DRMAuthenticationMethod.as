/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.drm
{
	/**
	 * This class is an enumeration of the 
	 * possible values of the DRMTrait and DRMServices
	 * authenticationMethod property. 
	 */ 
	public class DRMAuthenticationMethod
	{
		/**
		 * Indicates that no authentication is required.
		 */ 		
		public static const ANONYMOUS:String = "anonymous";
		
		/**
		 * Indicates that a valid user name and password are required.
		 */ 
		public static const USERNAME_AND_PASSWORD:String = "usernameAndPassword";
	}
}