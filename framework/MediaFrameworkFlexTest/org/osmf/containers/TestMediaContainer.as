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
package org.osmf.containers
{
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	
	import flexunit.framework.TestCase;
	
	import org.osmf.display.ScaleMode;
	import org.osmf.layout.LayoutUtils;
	import org.osmf.layout.RegistrationPoint;
	import org.osmf.layout.TesterSprite;
	import org.osmf.metadata.MetadataUtils;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.utils.DynamicMediaElement;

	public class TestMediaContainer extends TestCase
	{
		public function testRegionElements():void
		{
			var parent:MediaContainer = new MediaContainer();
			parent.backgroundColor = 0xff0000;
			parent.backgroundAlpha = 1;
			parent.clipChildren = true;
			
			var element1:DynamicMediaElement = new DynamicMediaElement();
			var element2:DynamicMediaElement = new DynamicMediaElement();
			
			assertNotNull(parent);
			assertFalse(parent.containsMediaElement(element1));
			assertFalse(parent.containsMediaElement(element2));
			
			parent.addMediaElement(element1);
			assertTrue(parent.containsMediaElement(element1));
			
			parent.addMediaElement(element2);
			assertTrue(parent.containsMediaElement(element2));
			
			assertTrue(element1 == parent.removeMediaElement(element1));
			assertFalse(parent.containsMediaElement(element1));
			
			var error:Error;
			try
			{
				parent.removeMediaElement(element1);
			}
			catch(e:Error)
			{
				error = e;
			}
			
			assertNotNull(error);
			assertTrue(error is IllegalOperationError);
		}
		
		public function testRegionSubRegions():void
		{
			var parent:MediaContainer = new MediaContainer();
			parent.backgroundColor = 0xff0000;
			parent.backgroundAlpha = 1;
			parent.clipChildren = true;
			
			var sub1:MediaContainer = new MediaContainer();
			var sub2:MediaContainer = new MediaContainer();
			
			assertNotNull(parent);
			assertFalse(parent.containsContainer(sub1));
			assertFalse(parent.containsContainer(sub2));
			
			parent.addChildContainer(sub1);
			assertTrue(parent.containsContainer(sub1));
			
			parent.addChildContainer(sub2);
			assertTrue(parent.containsContainer(sub2));
			
			parent.removeChildContainer(sub1);
			assertFalse(parent.containsContainer(sub1));
			
			var error:Error;
			try
			{
				parent.removeChildContainer(sub1);
			}
			catch(e:Error)
			{
				error = e;
			}
			
			assertNotNull(error);
			assertTrue(error is IllegalOperationError);
		}
		
		public function testRegionScaleAndAlign():void
		{
			// Child
			
			var mediaElement:DynamicMediaElement = new DynamicMediaElement();
			
			MetadataUtils.setElementId(mediaElement.metadata,"mediaElement");
			
			var viewSprite:Sprite = new TesterSprite();
			var viewTrait:DisplayObjectTrait = new DisplayObjectTrait(viewSprite, 486, 60);
			mediaElement.doAddTrait(MediaTraitType.DISPLAY_OBJECT, viewTrait);
			
			LayoutUtils.setLayoutAttributes(mediaElement.metadata, ScaleMode.NONE, RegistrationPoint.CENTER);

			var region:MediaContainer = new MediaContainer();
			LayoutUtils.setAbsoluteLayout(region.metadata, 800, 80);
			
			region.addMediaElement(mediaElement);
			
			region.validateContentNow();
			
			assertEquals(486, viewSprite.width);
			assertEquals(60, viewSprite.height);
			
			assertEquals(800/2 - 486/2, viewSprite.x);
			assertEquals(80/2 - 60/2, viewSprite.y);
		}
		
		public function testRegionAttributes():void
		{
			var region:MediaContainer = new MediaContainer();
			LayoutUtils.setAbsoluteLayout(region.metadata, 500, 400);
			
			assertEquals(NaN,region.backgroundColor);
			assertEquals(NaN,region.backgroundAlpha);
			
			region.backgroundColor = 0xFF00FF;
			assertEquals(0xFF00FF, region.backgroundColor);
			
			region.backgroundAlpha = 0.5;
			assertEquals(0.5, region.backgroundAlpha);
			
			assertFalse(region.clipChildren);
			region.clipChildren = true;
			assertTrue(region.clipChildren);
			
			assertEquals(500, region.width);
			assertEquals(400, region.height);
		}
		
		public function testNestedRegions():void
		{
			var root:MediaContainer = new MediaContainer();
			var childA:MediaContainer = new MediaContainer();
			var childA1:MediaContainer = new MediaContainer();
			var childA1A:MediaContainer = new MediaContainer();
			
			root.addChildContainer(childA);
			childA.addChildContainer(childA1);
			childA1.addChildContainer(childA1A);
			
			root.layoutRenderer.validateNow();
			
			assertEquals(NaN, root.width);
			assertEquals(NaN, root.height);
			assertEquals(NaN, root.calculatedWidth);
			assertEquals(NaN, root.calculatedHeight);
			assertEquals(NaN, root.projectedWidth);
			assertEquals(NaN, root.projectedHeight);
			
			LayoutUtils.setAbsoluteLayout(childA1A.metadata,400,50);
			root.layoutRenderer.validateNow();
			
			assertEquals(NaN, root.width);
			assertEquals(NaN, root.height);
			assertEquals(400, root.calculatedWidth);
			assertEquals(50, root.calculatedHeight);
			assertEquals(NaN, root.projectedWidth);
			assertEquals(NaN, root.projectedHeight);
			
			assertEquals(400, childA1A.width);
			assertEquals(50, childA1A.height);
			assertEquals(400, childA1A.calculatedWidth);
			assertEquals(50, childA1A.calculatedHeight);
			assertEquals(400, childA1A.projectedWidth);
			assertEquals(50, childA1A.projectedHeight);
			
			assertEquals(400, childA1.calculatedWidth);
			assertEquals(50, childA1.calculatedHeight);
			
			
		}
	}
}