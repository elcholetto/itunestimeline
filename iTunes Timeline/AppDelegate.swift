// This file is part of iTunes Timeline.
//
// © 2014 elcholetto (elcholetto@gmail.com)
//
// iTunes Timeline is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// iTunes Timeline. is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with iTunes Timeline. If not, see <http://www.gnu.org/licenses/>.

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching( aNotification: NSNotification? )
    {
        var scrollView = NSScrollView( frame: window.contentView!.frame )
        
        var parser = XmlDbParser()
        
        var timelineView = TimelineView( frame: window.contentView!.frame, parser: parser )
        
        scrollView.documentView = timelineView
        
        scrollView.autoresizingMask = NSAutoresizingMaskOptions.ViewHeightSizable | NSAutoresizingMaskOptions.ViewWidthSizable
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
        
        self.window!.contentView = scrollView
    }

    func applicationWillTerminate( aNotification: NSNotification? )
    {
        // Insert code here to tear down your application
    }
}

class Song
{
    var _name   = ""
    var _artist = ""
    var _album  = ""
    
    init( name: String, artist: String, album: String )
    {
        _name = name
        _artist = artist
        _album = album
    }
}

class XmlDbParser : NSObject, NSXMLParserDelegate
{
    var _songs:        [UInt64: Song]     = [:]
    var _songsForDate: [String: [(id: UInt64, time: String)]] = [:]
    var _datesForSong: [UInt64: [String]] = [:]
    
    var _currentId: UInt64 = 0
    var _currentSong: Song?
    
    var _insidePlayedOn = false
    
    override init()
    {
        super.init()
        
        println( "parsing db..." )
        
        var url = NSURL( string: "file:///Users/" + NSUserName() + "/Library/Application%20Support/iTunes%20Timeline/timelinedb.xml" )
        var xmlParser = NSXMLParser( contentsOfURL: url )
        xmlParser!.delegate = self

        if (xmlParser!.parse() == true)
        {
            println( "parse succeed!" )
            println( "found " + String(_songs.count) + " songs" )
        }
        else
        {
            println( "Parse failed :(" )
        }
        
        MakeSongsForDate()
    }
    
    func MakeSongsForDate()
    {
        for item in _datesForSong
        {
            for timestamp in item.1
            {
                var idx = advance( timestamp.startIndex, 10 )
                let date = timestamp.substringToIndex( idx )
                
                idx = advance( idx, 1 )
                let time = timestamp.substringFromIndex( idx )
                if (_songsForDate[date] == nil)
                {
                    _songsForDate[date] = []
                }
                
                _songsForDate[date]?.append( id: item.0, time: time )
            }
        }
    }
    
    func parser( parser: NSXMLParser!,
                 didStartElement elementName: String!,
                 namespaceURI: String!,
                 qualifiedName qName: String!,
                 attributes attributeDict: NSDictionary! )
    {
        _insidePlayedOn = false
        
        if (elementName == "track")
        {
            let id = attributeDict["id"] as String?
            if id != nil
            {
                NSScanner( string: id! ).scanHexLongLong( &_currentId )
                
                var name = attributeDict["name"] as NSString?
                var artist = attributeDict["artist"] as NSString?
                var album = attributeDict["album"] as NSString?
                
                _currentSong = Song(
                    name: name != nil ? name! : "",
                    artist: artist != nil ? artist! : "",
                    album: album != nil ? album! : "" )
                
                _songs[_currentId] = _currentSong
            }
            else
            {
                println( "Error: song has no id!" )
            }
        }
        
        else if (elementName == "playedon")
        {
            _insidePlayedOn = true
        }
    }
    
    func parser( parser: NSXMLParser, foundCharacters string: String )
    {
        if (_insidePlayedOn == true)
        {
            if (_datesForSong[_currentId] == nil)
            {
                _datesForSong[_currentId] = []
            }
            
            _datesForSong[_currentId]?.append( string )
        }
    }
}

