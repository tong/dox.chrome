package dox.chrome;

using Lambda;
using StringTools;

class App implements IApp {
		 // implements IExt {
	
	public static inline var VERSION = "0.2";
	
	static var defaultHaxeTargets = ["cpp","flash","js","neko","php"];
	static var defaultWebsiteSearches = ["haxe_wiki","haxe_ml","google_code","google_development","stackoverflow"];
	
	public static var online(default,null) : Bool;
	public static var api(default,null) : API;
	public static var webapp(default,null) : WebApp;
	
	static var omnibox : Omnibox;
	
	//public var use_omnibox(default,setUseOmnibox) : Bool;
//	public var haxe_targets(default,null) : Array<String>;
//	public var website_search_suggestions(default,null) : Array<String>;
	
	var websitesearches : Array<String>;
	var haxetargets : Array<String>;
	//var useomnibox : Bool;
	
	function new() {
	}
	
	/*
	function setUseOmnibox( v : Bool ) : Bool {
		if( v ) {
			if( omnibox == null ) omnibox = new Omnibox( this );
			omnibox.activate();
		} else {
			if( omnibox != null ) omnibox.deactivate();
		}
		return use_omnibox = v;
	}
	*/
	
	function init() {
		
		online =  untyped window.navigator.onLine;
		
		var version = LocalStorage.getItem( "version" );
		if( version == null ) { // extension version was < 0.2
			trace( "Previous DoX version was < 0.2 .. going to delete my local cache" );
			try LocalStorage.clear() catch( e : Dynamic ) trace( e, "warn" );
			try {
				var fs = new dsi.FileSystem();
				fs.init( 1, function(e){
					fs.delete( "api", function(e){
						if( e != null ) trace( "Local filesystem cleared" ) else trace(e);
					} );
				});
			} catch( e : Dynamic ) {
				trace( e, "warn" );
			}
		} else {
			//TODO compare versions
		}
		
		LocalStorage.setItem( "version", VERSION );
		
		var d = LocalStorage.getItem( "haxetargets" );
		if( d == null ) {
			haxetargets = defaultHaxeTargets;
			saveHaxetargets();
		} else {
			haxetargets = JSON.parse( d );
		}
		d = LocalStorage.getItem( "websitesearches" );
		if( d == null ) {
			websitesearches = defaultWebsiteSearches;
			saveWebsitesearches();
		} else {
			websitesearches = JSON.parse( d );
		}
		
		var stime = haxe.Timer.stamp();
		
		api = new API();
		api.init( function(e){
			if( e != null ) {
				//TODO
				trace( e );
			} else {
				trace( haxe.Timer.stamp()-stime );
				run();
			}
		});
	}
	
	function run() {
	//	if( use_omnibox ) {
			omnibox = new Omnibox( this );
			omnibox.activate();
	//	}
	/*
		webapp = new WebApp();
		webapp.init();
	*/
	}
	
	/// ---------- IApp ----------
	
	public function getHaxeTargets() : Array<String> {
		return haxetargets.copy();
	}
	
	public function addHaxeTarget( t : String ) : Bool {
		if( haxetargets.has(t) )
			return false;
		haxetargets.push( t );
		saveHaxetargets();
		//omnibox.platforms = haxetargets.copy();
		return true;
	}
	
	public function removeHaxeTarget( t : String ) : Bool {
		var r = haxetargets.remove( t );
		if( !r ) return false;
		saveHaxetargets();
		return true;
	}
	
	public function getWebsiteSearchSuggestions() : Array<String> {
		return websitesearches.copy();
	}
	
	public function addWebsiteSearchSuggestion( t : String ) : Bool {
		if( websitesearches.has(t) )
			return false;
		websitesearches.push( t );
		saveWebsitesearches();
		return true;
	}
	
	public function removeWebsiteSearchSuggestion( t : String ) : Bool {
		var r = websitesearches.remove( t );
		if( !r ) return false;
		saveWebsitesearches();
		return true;
	}
	
	public function clearWebsiteSearchSuggestions() {
		if( websitesearches.length == 0 )
			return;
		websitesearches = new Array();
		LocalStorage.setItem( "websitesearches", JSON.stringify( websitesearches ) );
	}
	
	public function resetSettings() {
		trace( "Resetting ..." );
		LocalStorage.clear();
		LocalStorage.setItem( "version", VERSION );
		haxetargets = defaultHaxeTargets;
		saveHaxetargets();
		websitesearches = defaultWebsiteSearches;
		saveWebsitesearches();
	}
	
	#if DEBUG
	public function log( v : Dynamic, ?inf : haxe.PosInfos ) haxe.Log.trace( v, inf )
	#end
	
	/// ---------- IExt ----------
	//..
	
	//--------------------------------------
	
	function saveHaxetargets() {
		LocalStorage.setItem( "haxetargets", JSON.stringify( haxetargets ) );
	}
	
	function saveWebsitesearches() {
		LocalStorage.setItem( "websitesearches", JSON.stringify( websitesearches ) );
	}
	
	/*
	function xhr( url : String ) {
		var w = new Worker( "js/worker/xhr.js" );
		w.onmessage = function(e) {
			//TODO
			var d : String = e.data;
			if( !d.startsWith( "error" ) ) {
				trace("remote loaded");
			} else {
				trace("ERROR "+d );
			}
		}
		w.postMessage( url );
	}
	*/
	
	//--------------------------------------
	
	public static function nav( url : String ) {
		chrome.Tabs.getSelected( null, function(tab) { chrome.Tabs.update( tab.id, { url : url } ); } );
	}
	
	static function __init() : IApp {
		#if DEBUG
		if( haxe.Firebug.detect() ) haxe.Firebug.redirectTraces();	
		trace( "----------------- DoX.chrome -----------------" );
		#end
		var a : IApp = new App();
		return a;
	}
	
}
