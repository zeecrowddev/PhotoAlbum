/**
* Copyright (c) 2010-2014 "Jabber Bees"
*
* This file is part of the WebApp application for the Zeecrowd platform.
*
* Zeecrowd is an online collaboration platform [http://www.zeecrowd.com]
*
* WebApp is free software: you can redistribute it and/or modify
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

import QtQuick 2.0
import QtQuick.Controls 1.0

import ZcClient 1.0 as Zc

import "../Tools.js" as Tools


Rectangle
{
    id : chatDelegate

    property alias contactImageSource : contactImage.source

    height : 50
    width : parent.width

    color : "white"

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


        function updateDelegate()
        {
            var o = Tools.parseDatas(body);

            textEdit.text = o.text;


            textZone.url = o.viewUrl;

            console.log(">> textZone.url " + textZone.url)

            var ligneHeight =  textEdit.lineCount * 17

            var finalHeight = 28 + ligneHeight;

            if (finalHeight < 70 )
                finalHeight = 70;

            textZone.height = finalHeight;
            chatDelegate.height = finalHeight;
        }


        Component.onCompleted:
        {
            updateDelegate();
            chatView.goToEnd()
        }



        Label
        {
            id                      : fromId
            text                    : from
            color                   : "black"
            font.pixelSize          : appStyleId.baseTextHeigth
            anchors
            {
                top             : parent.top
                topMargin       : 2
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
            id                      : timeStampId
            text                    : timeStamp
            font.pixelSize          : 10
            font.italic 			: true
            anchors
            {
                top             : parent.top
                horizontalCenter: parent.horizontalCenter
            }
            maximumLineCount        : 1
            elide                   : Text.ElideRight
            wrapMode                : Text.WrapAnywhere
            color                   : "gray"
        }


        Item
        {

            clip : true

            anchors
            {
                top        : fromId.bottom
                left       : parent.left
                leftMargin : 25
                right      : viewImage.left
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

        Image
        {
            id : viewImage

            height: 50
            width: 50
            anchors.top : parent.top
            anchors.topMargin : 2
            anchors.right : parent.right
            anchors.rightMargin : 2

            source : textZone.url
        }


        Label
        {
            height : 20
            width : 100
            anchors.bottom: parent.bottom
            anchors.left: textZone.right
            anchors.leftMargin: - 30
            text : "<a href=\" \">view</a>"

            onLinkActivated:
            {
                preview.source = textZone.url
            }
        }

    }
}
