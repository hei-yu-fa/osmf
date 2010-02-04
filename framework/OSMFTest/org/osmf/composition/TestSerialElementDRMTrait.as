package org.osmf.composition
{

	import flash.utils.ByteArray;
	
	import flexunit.framework.Assert;
	import flexunit.framework.TestCase;
	
	import org.osmf.drm.DRMAuthenticationMethod;
	import org.osmf.drm.DRMState;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.DynamicDRMTrait;
	import org.osmf.utils.DynamicMediaElement;
	import org.osmf.utils.DynamicTimeTrait;

	public class TestSerialElementDRMTrait extends TestCase
	{
		public function testSerialProperties():void
		{
			var elem:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			var elem2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			
			var serial:SerialElement = new SerialElement();
			
			Assert.assertFalse(serial.getTrait(MediaTraitType.DRM) != null);
			
			serial.addChild(elem);
			serial.addChild(elem2);
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
			
			var elem1Drm:DynamicDRMTrait = elem.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var elem2Drm:DynamicDRMTrait = elem2.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var timeTrait1:DynamicTimeTrait = elem.getTrait(MediaTraitType.TIME) as  DynamicTimeTrait;		
			timeTrait1.duration = 1;	
			
			elem.doAddTrait(MediaTraitType.TIME, timeTrait1);
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
			
			var trait:DRMTrait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;
			
			Assert.assertEquals(trait.drmState, elem1Drm.drmState);
			Assert.assertEquals(trait.endDate, elem1Drm.endDate);
			Assert.assertEquals(trait.serverURL, elem1Drm.serverURL);
			Assert.assertEquals(trait.startDate, elem1Drm.startDate);
			Assert.assertEquals(trait.period, elem1Drm.period);
			
			//Moves the serial element to the next child.							
			timeTrait1.currentTime = 1;
		
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
			
			trait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;
			
			Assert.assertEquals(trait.drmState, elem2Drm.drmState);
			Assert.assertEquals(trait.endDate, elem2Drm.endDate);
			Assert.assertEquals(trait.serverURL, elem2Drm.serverURL);
			Assert.assertEquals(trait.startDate, elem2Drm.startDate);
			Assert.assertEquals(trait.period, elem2Drm.period);
			Assert.assertEquals(trait.authenticationMethod,  "");
						
			var start:Date = new Date(1);
			var end:Date = new Date(2);
			
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATED,  new ByteArray(), new MediaError(1, "test"), start, end, 50, "server", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			
			Assert.assertEquals(trait.drmState, DRMState.AUTHENTICATED);
			Assert.assertEquals(trait.endDate, end);
			Assert.assertEquals(trait.startDate, start);
			Assert.assertEquals(trait.serverURL, "server");
			Assert.assertEquals(trait.period, 50);
			Assert.assertEquals(trait.authenticationMethod,  DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
									
		}
		
		public function testSerialEvents():void
		{
			var elem:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			var elem2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			
			var serial:SerialElement = new SerialElement();
					
			serial.addChild(elem);
			serial.addChild(elem2);
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
			
			var elem1Drm:DynamicDRMTrait = elem.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var elem2Drm:DynamicDRMTrait = elem2.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var timeTrait1:DynamicTimeTrait = elem.getTrait(MediaTraitType.TIME) as  DynamicTimeTrait;		
			timeTrait1.duration = 1;	
			
			elem.doAddTrait(MediaTraitType.TIME, timeTrait1);
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
			
			var trait:DRMTrait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;			
			trait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
							
			Assert.assertEquals(trait.drmState, DRMState.INITIALIZING);
					
			var currentDRMTrait:DRMTrait = 	elem1Drm;
			
			var token:ByteArray = new ByteArray();		
			
			var events:Number = 0;		
					
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATE_FAILED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATING, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem1Drm.invokeDrmStateChange(DRMState.INITIALIZING, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);		
			
			currentDRMTrait = elem2Drm;
						
			//Moves the serial element to the next child.							
			timeTrait1.currentTime = 1;
				
			elem2Drm.invokeDrmStateChange(DRMState.INITIALIZING, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);	
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATE_FAILED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATING, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, token, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			
						
			//Test init
				
			serial.removeChild(elem);
			
			assertEquals(trait.drmState, elem2Drm.drmState);
					
			function onDRMStateChange(event:DRMEvent):void
			{
				events++;
				assertEquals(event.token, token);
				assertEquals(event.serverURL, "SeverURL");
				assertEquals(trait.drmState, currentDRMTrait.drmState, event.drmState);	
			}
			
			assertEquals(events, 9);
			
		}
		
		public function testAuthentication():void
		{
			var events:Number = 0;		
			var eventQueue:Array = [DRMState.AUTHENTICATED, DRMState.AUTHENTICATING, DRMState.AUTHENTICATION_NEEDED,  DRMState.AUTHENTICATED, DRMState.AUTHENTICATING];
			var elem:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			var elem2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);			
			var serial:SerialElement = new SerialElement();
			var elem1Drm:DynamicDRMTrait = elem.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var elem2Drm:DynamicDRMTrait = elem2.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;		
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);	

			serial.addChild(elem);
			serial.addChild(elem2);
			
			var trait:DRMTrait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;	
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
					
			trait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
			
			trait.authenticate("ryan", "password");
													
			function onDRMStateChange(event:DRMEvent):void
			{
				assertEquals(event.drmState, eventQueue.pop());
				events++;						
			}
			
			assertEquals( events, 2);
			
			//Move the serial to the next element
			var time:DynamicTimeTrait = elem.getTrait(MediaTraitType.TIME) as DynamicTimeTrait;
			time.duration = 1;
			time.currentTime = 1;
									
			trait.authenticate("ryan2", "password2");
			
			assertEquals(events, 5);
		}
		
			
		public function testAuthenticationToken():void
		{
			var events:Number = 0;		
			var eventQueue:Array = [DRMState.AUTHENTICATED, DRMState.AUTHENTICATING, DRMState.AUTHENTICATION_NEEDED, DRMState.AUTHENTICATED, DRMState.AUTHENTICATING];
			var elem:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			var elem2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);			
			var serial:SerialElement = new SerialElement();
			var elem1Drm:DynamicDRMTrait = elem.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var elem2Drm:DynamicDRMTrait = elem2.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;		
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);	

			serial.addChild(elem);
			serial.addChild(elem2);
			
			var trait:DRMTrait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;	
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
					
			trait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
			
			trait.authenticateWithToken(new ByteArray());
													
			function onDRMStateChange(event:DRMEvent):void
			{
				assertEquals(event.drmState, eventQueue.pop());
				events++;						
			}
			
			assertEquals( events, 2);
			
			//Move the serial to the next element
			var time:DynamicTimeTrait = elem.getTrait(MediaTraitType.TIME) as DynamicTimeTrait;
			time.duration = 1;
			time.currentTime = 1;
									
			trait.authenticateWithToken(new ByteArray());
			
			assertEquals(events, 5);
		}
		
		public function testAuthFailure():void
		{
			var events:Number = 0;		
			var eventQueue:Array = [DRMState.AUTHENTICATED, DRMState.AUTHENTICATING, DRMState.AUTHENTICATION_NEEDED, DRMState.AUTHENTICATE_FAILED, DRMState.AUTHENTICATING];
			var elem:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);
			var elem2:DynamicMediaElement = new DynamicMediaElement([MediaTraitType.DRM, MediaTraitType.TIME, MediaTraitType.PLAY], null, null, true);			
			var serial:SerialElement = new SerialElement();
			var elem1Drm:DynamicDRMTrait = elem.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;			
			var elem2Drm:DynamicDRMTrait = elem2.getTrait(MediaTraitType.DRM) as DynamicDRMTrait;		
			elem1Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);
			elem2Drm.invokeDrmStateChange(DRMState.AUTHENTICATION_NEEDED, null, null, new Date(), new Date(), 50, "SeverURL", DRMAuthenticationMethod.USERNAME_AND_PASSWORD);	

			serial.addChild(elem);
			serial.addChild(elem2);
			
			var trait:DRMTrait = serial.getTrait(MediaTraitType.DRM) as DRMTrait;	
			
			Assert.assertTrue(serial.getTrait(MediaTraitType.DRM) != null);
					
			trait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
			
			trait.authenticate();
													
			function onDRMStateChange(event:DRMEvent):void
			{
				assertEquals(event.drmState, eventQueue.pop());
				events++;						
			}
			
			assertEquals( events, 2);
			
			//Move the serial to the next element
			var time:DynamicTimeTrait = elem.getTrait(MediaTraitType.TIME) as DynamicTimeTrait;
			time.duration = 1;
			time.currentTime = 1;
									
			trait.authenticateWithToken(new ByteArray());
			
			assertEquals(events, 5);
		}
				
		
		
	}
}