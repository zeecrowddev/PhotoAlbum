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

import QtQuick 2.2
import QtQuick.Controls 1.1


FocusScope
{
    id : input
    height : 75

    signal accepted(string message);

    function setFocus()
    {
        textField.focus = true;
        textField.forceActiveFocus();
    }


    Rectangle
    {
        id : background
        anchors
        {
            top : parent.top
            bottom : parent.bottom
            left : parent.left
            right : parent.right
            rightMargin : 5
            leftMargin : 5
        }
        color : input.focus ?  Qt.lighter("#ff6600") : "white"

        border.width: 1
        border.color: "black"
    }

    states :
        [
        State
        {
            name   : "chat"
            StateChangeScript {
                script:
                {
                    input.visible = true;
                    input.enabled = true;
                    textField.readOnly = false;
                    textField.visible = true
                }
            }
        }
        ,
        State
        {
            name   : "unvisible"
            StateChangeScript {
                script:
                {
                    input.visible = false;
                    input.enabled = false;
                    textField.visible = false
                    textField.readOnly = true;

                }
            }
        }


    ]

    ScrollView
    {
        anchors.top: background.top
        anchors.topMargin: 2
        anchors.bottom: background.bottom
        anchors.left: background.left
        anchors.leftMargin: 5
        anchors.right: background.right
        anchors.rightMargin: 5


        TextEdit
        {
            id : textField

            width : background.width - 50
            height : background.height - 2  > lineCount * 19 ? background.height - 2 : lineCount * 19

            font.pixelSize: 16

//            textFormat: TextEdit.AutoText

            wrapMode: TextEdit.WrapAnywhere

            Keys.onPressed:
            {

                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                {
                    event.accepted = true
                    if (!(event.modifiers & Qt.AtltModifier))
                    {
                        if (text == "" ||text == null)
                            return;

                        var o = {}
                        o.text = text

                        o.viewUrl = preview.source.toString();

                        input.accepted(JSON.stringify(o));
                        text = "";
                    }
                    else
                    {
                        textField.append("")
                    }
                }
            }
        }
    }
}
