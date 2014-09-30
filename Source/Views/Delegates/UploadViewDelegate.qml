/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the PhotoAlbum application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* ChatTabs is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import "../Tools.js" as Tools

Rectangle
{
    height : 20
    width : parent.width
    color : index % 2 ? "lightgrey" : "white"

    Row
    {
        anchors.fill: parent
        Label
        {
            id :lbStatus
            height : 20 ;
            width : 200 ;
            text: status ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            id : lbName
            height : 20 ;
            width : 200 ;

            text: name ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            height : 20 ;

            width  : 400

            text: message ;
            color : "black";
            font.pixelSize:  16
        }
        Button
        {
            height : 20 ;
            width  : 80
            text: "Cancel"

            onClicked:
            {
                mainView.cancelUpload(name);
            }
        }
    }

    ProgressBar
    {
        anchors.fill: parent
        visible : progress > 0
        opacity: 0.5

        height : parent.height
        width  : parent.width

        minimumValue: 0
        maximumValue: 100
        value       : progress

        style : ProgressBarStyle {}
    }

}
