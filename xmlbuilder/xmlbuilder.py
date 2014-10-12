#!/usr/bin/python
# -*- coding: utf-8 -*-

# This file is part of iTunes Timeline.
#
# © 2014 elcholetto (elcholetto@gmail.com)
#
# iTunes Timeline is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

import getpass
import os.path, sys, inspect
from datetime import datetime
import xml.etree.ElementTree as etree
#from lxml import etree

# add local pyitunes into python search path
# realpath() will make your script run, even if you symlink it :)
cmd_folder = os.path.realpath(os.path.abspath(os.path.split(inspect.getfile( inspect.currentframe() ))[0]))
if cmd_folder not in sys.path:
    sys.path.insert(0, cmd_folder)

# use this if you want to include modules from a subfolder
cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0], "pyitunes")))
if cmd_subfolder not in sys.path:
    sys.path.insert(0, cmd_subfolder)

from pyItunes import *

def timetoisoformat( time ):
    return datetime( *time[:6] ).isoformat()

"""def indent( elem, level=0 ):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i """

def setSongMetadata( songNode, song ):
    if song.name is not None:
        songNode.set( "name", song.name )
        
    if song.artist is not None:
        songNode.set( "artist", song.artist )
    
    if song.album is not None:
        songNode.set( "album", song.album )
    
    if song.year is not None:
        songNode.set( "year", str(song.year) )
    
    if song.date_added is not None:
        songNode.set( "added", timetoisoformat( song.date_added ) )
    
    if song.play_count is not None:
        songNode.set( "playcount", str(song.play_count) )

def getSongNode( timelineDB, id ):
    songs = timelineDB.findall(".//track[@id='" + str(id) + "']")
    nbSongs = len( songs )
    
    if nbSongs > 1:
        print "WARNING: more than one songs for id " + str(id)
    
    if nbSongs > 0:
        return songs[0]
    else:
        return None

def getNodeText( node ):
    return node.text
        
def updatedb( itunesLib, timelineDB ):
    print "building iTunes Timeline db (this may take a while)..."
    for id, song in itunesLib.songs.items():
        songNode = getSongNode( timelineDB, song.persistentid )
        
        # create node for new song
        if songNode is None:
            songNode = etree.SubElement( timelineDB, "track" )
            songNode.set( "id", str( song.persistentid ) )
        
        # update metadata
        setSongMetadata( songNode, song )
        
        # fetch all playedon timestamp
        lastPlayedList = songNode.findall( ".//playedon" )
        
        if lastPlayedList is not None and len(lastPlayedList) > 0:
            lastPlayed = sorted( lastPlayedList, key=getNodeText, reverse=True )[0]
            if lastPlayed.text < timetoisoformat( song.lastplayed ):
                #print lastPlayed.text + " is smaller than " + timetoisoformat( song.lastplayed )
                print "INFO: adding new timestamp " + timetoisoformat( song.lastplayed ) + " for '" + song.artist + " - " + song.name + "'"
                playedon = etree.SubElement( songNode, "playedon" )
                playedon.text = timetoisoformat( song.lastplayed )
        else:
            if song.lastplayed is not None:
                #print "INFO: adding new timestamp for '" + song.artist + " - " + song.name + "'"
                print "INFO: adding new timestamp " + timetoisoformat( song.lastplayed ) + " for '" + song.artist + " - " + song.name + "'"
                playedon = etree.SubElement( songNode, "playedon" )
                playedon = etree.SubElement( songNode, "playedon" )
                playedon.text = timetoisoformat( song.lastplayed )

    # saving modification
    tree = etree.ElementTree( timelineDB )
    tree.write( "timelinedb.xml" ) #, pretty_print=True ) 

###############################################################################
# main of some sort
print "iTunes timeline xml db builder v0.1"
print "© 2014 elcholetto (elcholetto@gmail.com)"

currentUser = getpass.getuser()
defaultLibPath = "/Users/" + currentUser + "/Music/iTunes/iTunes Music Library.xml"

# open itunes library file
if os.path.isfile( defaultLibPath ):
    print "opening iTunes library file..."
    itunesLib = Library( defaultLibPath )
else:
    print "ERROR: could not open iTunes library file."
    sys.exit(-1)

if os.path.isfile( "timelinedb.xml" ):
    print "opening iTunes Timeline db..."
    filehandler = open( "timelinedb.xml", "r" )
    raw_data = etree.parse(filehandler)
    timelineDB = raw_data.getroot()
    filehandler.close()
else:
    timelineDB = etree.Element( "timeline" )
    
updatedb( itunesLib, timelineDB )

print "done."
sys.exit( 0 ) 
    
    
    
