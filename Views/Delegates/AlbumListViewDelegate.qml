    /*
** Copyright (c) 2014, Jabber Bees
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without modification,
** are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
** in the documentation and/or other materials provided with the distribution.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
** INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
** ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

