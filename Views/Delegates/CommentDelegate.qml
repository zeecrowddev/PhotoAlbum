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
import QtQuick.Controls 1.2

import ZcClient 1.0 as Zc

import "../Tools.js" as Tools


Item
{
    id : commentDelegate

    property alias contactImageSource : contactImage.source

    height : 50
    width : parent.width


    /*
    ** Contact Image
    ** default contact image set
    */
    Image
    {
        id : contactImage

        width  : 50
        height : width

        anchors
        {
            top        : parent.top
            topMargin  : 2
            left       : parent.left
            leftMargin : 2
        }

        onStatusChanged:
        {
            if (status === Image.Error)
            {
                source = "qrc:/Crowd.Core/Qml/Ressources/Pictures/DefaultUser.png"
            }
        }
    }

    Item
    {
        id : textZone

        anchors.top : parent.top
        anchors.left : contactImage.right
        anchors.leftMargin : 5


        height : 50
        width : parent.width - 60


        property string url : ""


        function updateDelegate(text)
        {

            textEdit.text = text;


            var ligneHeight =  textEdit.lineCount * 17

            var finalHeight = 28 + ligneHeight;

            if (finalHeight < 70 )
                finalHeight = 70;

            textZone.height = finalHeight;
            commentDelegate.height = finalHeight;
        }

        Component.onCompleted:
        {
            updateDelegate(model.comment);
        }



        Label
        {
            id                      : fromId
            text                    : model.who
            color                   : "black"
            font.pixelSize          : appStyleId.baseTextHeigth
            anchors
            {
                top             : parent.top
                left            : parent.left
                leftMargin      : 5
            }

            maximumLineCount        : 1
            font.bold               : true
            elide                   : Text.ElideRight
            wrapMode                : Text.WrapAnywhere
        }


        Label
        {
            function getDate(x)
            {
                if (x !== null && x !== undefined && x !== "")
                {
                    return new Date(parseInt(x)).toDateString();
                }
                return new Date(0).toDateString();
            }

            id                      : timeStampId
            text                    : getDate(model.date)
            font.pixelSize          : 10
            font.italic 			: true
            anchors
            {
                top             : parent.top
                right           : parent.right
                rightMargin     : 2
            }
            maximumLineCount        : 1
            elide                   : Text.ElideRight
            wrapMode                : Text.WrapAnywhere
            color                   : "gray"

            horizontalAlignment: Text.AlignRight
        }


        Item
        {

            clip : true

            anchors
            {
                top        : fromId.bottom
                left       : parent.left
                leftMargin : 25
                right      : parent.right
                rightMargin: 5
                bottom     : parent.bottom
            }

            TextEdit
            {
                id  : textEdit
                color : "black"

                textFormat: Text.RichText

                anchors
                {
                    top         : parent.top
                    left        : parent.left
                    leftMargin  : 5
                    right       : parent.right
                    bottom      : parent.bottom
                }

                readOnly                : true
                selectByMouse           : true
                font.pixelSize          : 14
                wrapMode                : TextEdit.WrapAtWordBoundaryOrAnywhere

            }

        }
    }

    Rectangle
    {
        height : 1
        width : parent.width - 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        color : "grey"
    }

}
