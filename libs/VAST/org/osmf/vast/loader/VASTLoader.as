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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.vast.loader
{
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.logging.ILogger;
	import org.osmf.logging.Log;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.HTTPLoadedContext;
	import org.osmf.utils.HTTPLoader;
	
	/**
	 * Loader for a VAST Document.  The load process is complete when
	 * the request for the document has been fulfilled, and the VAST
	 * document has been parsed into a VAST document object model.
	 * 
	 * @see http://www.iab.net/vast
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class VASTLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param maxNumWrapperRedirects The maximum number of redirects
		 * allowed when retrieving wrapper documents.  The default is -1
		 * (no limit).
		 * @param The HTTPLoader to be used by this VASTLoader to retrieve
		 * the VAST document.  If null, then a new one will be created on
		 * demand.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VASTLoader(maxNumWrapperRedirects:Number=-1, httpLoader:HTTPLoader=null)
		{
			super();
			
			this.maxNumWrapperRedirects = maxNumWrapperRedirects;
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();			
		}
		
		/**
		 * Returns true for HTTP(s) resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return httpLoader.canHandleResource(resource);
		}
		
		/**
		 * Loads a VAST document. 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to LOADING
		 * while loading and to READY upon completing a successful load and parse of the 
		 * VAST document.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @see flash.display.Loader#load()
		 * @param LoadTrait LoadTrait to be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override public function load(loadTrait:LoadTrait):void
		{
			super.load(loadTrait);
			
			updateLoadTrait(loadTrait, LoadState.LOADING);
			
			// We'll use an HTTPLoader to do the loading.
			httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
			
			// Create a temporary LoadTrait for this purpose, so that our main
			// LoadTrait doesn't reflect any of the state changes from the
			// loading of the URL, and so that we can catch any errors.
			var httpLoadTrait:LoadTrait = new LoadTrait(httpLoader, loadTrait.resource);
			httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
			
			CONFIG::LOGGING
			{
				logger.debug("Downloading document at " + URLResource(loadTrait.resource).url.rawUrl + ", " + maxNumWrapperRedirects + " wrapper redirects left");
			}
			
			httpLoader.load(httpLoadTrait);
			
			function onHTTPLoaderStateChange(event:LoaderEvent):void
			{
				if (event.newState == LoadState.READY)
				{
					// This is a terminal state, so remove all listeners.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
	
					var loadedContext:HTTPLoadedContext = event.loadedContext as HTTPLoadedContext;
					
					// Use a separate processor class to parse the document.
					var processor:VASTDocumentProcessor = new VASTDocumentProcessor(maxNumWrapperRedirects, httpLoader);
					toggleProcessorListeners(processor, true);
					processor.processVASTDocument(loadedContext.urlLoader.data);

					function toggleProcessorListeners(processor:VASTDocumentProcessor, add:Boolean):void
					{
						if (add)
						{
							processor.addEventListener(VASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed);
							processor.addEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, onDocumentProcessFailed);
						}
						else
						{
							processor.removeEventListener(VASTDocumentProcessedEvent.PROCESSED, onDocumentProcessed);
							processor.removeEventListener(VASTDocumentProcessedEvent.PROCESSING_FAILED, onDocumentProcessFailed);
						}
					}

					function onDocumentProcessed(event:VASTDocumentProcessedEvent):void
					{
						toggleProcessorListeners(processor, false);
					
						updateLoadTrait(loadTrait, LoadState.READY, new VASTLoadedContext(event.vastDocument));
					}
					
					function onDocumentProcessFailed(event:VASTDocumentProcessedEvent):void
					{
						toggleProcessorListeners(processor, false);

						updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					}
				}
				else if (event.newState == LoadState.LOAD_ERROR)
				{
					// This is a terminal state, so remove the listener.  But
					// don't remove the error event listener, as that will be
					// removed when the error event for this failure is
					// dispatched.
					httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
					
					updateLoadTrait(loadTrait, event.newState);
				}
			}
			
			function onLoadTraitError(event:MediaErrorEvent):void
			{
				// Only remove this listener, as there will be a corresponding
				// event for the load failure.
				httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadTraitError);
				
				loadTrait.dispatchEvent(event.clone());
			}
		}
	
		/**
		 * Unloads the document.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadedState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param LoadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		override public function unload(loadTrait:LoadTrait):void
		{
			super.unload(loadTrait);

			// Nothing to do.
			updateLoadTrait(loadTrait, LoadState.UNLOADING, loadTrait.loadedContext);			
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		

		CONFIG::LOGGING
		private static const logger:ILogger = Log.getLogger("VASTLoader");

		private var maxNumWrapperRedirects:int;
		private var httpLoader:HTTPLoader;
	}
}
