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

Item
{
    width: 100
    height: 62

    id : delegateId

    signal clicked (int index)

    property Item gridView : null

    Image
    {

        Rectangle
        {
            visible : model.cast.datas !== ""

            anchors.top : parent.top
            anchors.right : parent.right

            height : 20
            width : 20

            radius : 2

            color : "orange"

            opacity : 0.8

            Label
            {
                anchors.fill        : parent
                text                : model.cast.datas
                horizontalAlignment : Text.AlignHCenter
            }

        }

        id : image
        width : parent.width - 10
        height: width
        anchors.centerIn: parent

        fillMode: Image.PreserveAspectFit

        source : documentFolder.getUrl(model.cast)

        sourceSize.width: 100

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
                delegateId.clicked(index)
            }
        }
    }

//    Component.onCompleted:
//    {
//        model.cast.isSelectedChanged.connect(function () {
//            checkBox.checked = model.cast.isSelected;
//        })
//    }

    function selectUnselect(val)
    {
        checkBox.checked = val;
    }

    Component.onCompleted :
    {
        gridView.onSelectedAllChanged.connect(selectUnselect);
        checkBox.checked = model.cast.isSelected;
    }

    Component.onDestruction:
    {
        gridView.onSelectedAllChanged.disconnect(selectUnselect);
    }

    CheckBox
    {
        id : checkBox
        anchors.top : parent.top
        anchors.left : parent.left
        anchors.topMargin : 2
        anchors.leftMargin : 2
        style : CheckBoxStyle {}

        onCheckedChanged:
        {
            model.cast.isSelected = checked
        }
    }

    ProgressBar
    {
        anchors.centerIn: parent
        visible : image.status === Image.Loading
        opacity: 0.5

        height : 20
        width : parent.width - 10
        minimumValue: 0
        maximumValue: 1
        value       : image.progress

        style: ProgressBarStyle{}
    }
}

