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
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import ZcClient 1.0 as Zc

import "./Delegates"
import "Tools.js" as Tools


Item
{

    focus : true

    anchors.fill: parent


    function setModel(model)
    {
        listView.model = model
    }

    function setPreviewSource(source)
    {
        preview.source = source;
    }

    function showPreview()
    {
        if (previewItem.height === 0)
        {
            previewItem.height = parent.height * 2 / 3
        }
    }

    function closePreview()
    {
        previewItem.height = 0;
    }

    signal clean();

    SplitView
    {
        anchors.fill: parent

        orientation: Qt.Vertical

        handleDelegate : handleDelegateVertical

        Item
        {
            id : previewItem

            height : 0

            Image
            {
                id : preview
                anchors
                {
                    top : parent.top
                    right : parent.right
                    left : parent.left
                    bottom : parent.bottom
                    bottomMargin : 70
                    topMargin : 10
                }

                fillMode: Image.PreserveAspectFit
            }

            Row
            {
                width : 110
                height : 50
                spacing: 10

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button
                {
                    width : 50
                    height : 50


                    style:
                        ButtonStyle {
                        background: Rectangle {
                            implicitWidth: 50
                            implicitHeight: 50

                            color : control.pressed ? "#EEEEEE" : "#00000000"
                            radius: 4

                            Image
                            {
                                source : "qrc:/PhotoAlbum/Resources/previous.png"
                                anchors.fill: parent
                            }
                        }
                    }

                    onClicked:
                    {
                        if (listView.currentIndex > 0 )
                            listView.currentIndex = listView.currentIndex - 1
                    }
                }

                Button
                {
                    width : 50
                    height : 50


                    style:
                        ButtonStyle {
                        background: Rectangle {
                            implicitWidth: 50
                            implicitHeight: 50

                            color : control.pressed ? "#EEEEEE" : "#00000000"
                            radius: 4

                            Image
                            {
                                source : "qrc:/PhotoAlbum/Resources/next.png"
                                anchors.fill: parent
                            }
                        }
                    }

                    onClicked:
                    {
                        if ( listView.currentIndex + 1 <  listView.model.count  )
                            listView.currentIndex = listView.currentIndex + 1

                    }
                }
            }

            ProgressBar
            {
                anchors.centerIn: preview
                visible : preview.status === Image.Loading
                opacity: 0.5

                height : 20
                width : preview.paintedWidth - 10
                minimumValue: 0
                maximumValue: 1
                value       : preview.progress

                style: ProgressBarStyle{}
            }
        }

        Item
        {
            Layout.fillHeight : true
            Layout.fillWidth : true

            CheckBox
            {
                id : selectUnselect

                height : 10
                width : 30

                anchors.verticalCenter: slider.verticalCenter
                anchors.left    : parent.left
                anchors.leftMargin    : 5
                anchors.right   : parent.right

                style : CheckBoxStyle {}

                onCheckedChanged:
                {

                    Tools.forEachInObjectList( listView.model, function(file)
                    {
                        file.cast.isSelected = checked;
                    })
                }
            }

            Slider
            {
                id              : slider
                anchors.top     : parent.top
                anchors.topMargin : 5
                anchors.left    : parent.left
                anchors.leftMargin : 30
                anchors.right   : parent.right
                anchors.rightMargin : 5

                height: 30

                value : 1

                maximumValue: 2
                minimumValue: 0.5
                stepSize: 0.1

                orientation : Qt.Horizontal

                style : SliderStyle {}
            }

            ScrollView
            {

                anchors.top     : slider.bottom
                anchors.left    : selectUnselect.left
                anchors.right   : slider.right
                anchors.bottom  : parent.bottom


                // ListView
                GridView
                {

                    Component
                    {
                        id: highlight

                        Rectangle
                        {
                            height      : appStyleId.baseHeight / 2 + 4
                            width       : appStyleId.baseHeight * 1.5

                            border.width: 5
                            border.color: "orange"
                            color: "#00000000"
                            z : 100
                        }
                    }

                    onCurrentIndexChanged:
                    {
                        if (currentIndex >= 0)
                        {
                            showPreview();
                            preview.source =    documentFolder.getUrl(model.get(currentIndex));
                        }
                        else
                        {
                            closePreview();
                            preview.source = "";
                        }

                    }

                    highlight: highlight
                    highlightFollowsCurrentItem: true

                    id : listView
                    anchors.top  : parent.top
                    anchors.left: parent.left

                    width : slider.width

                    clip : true

                    cellHeight : 150 * slider.value + 10
                    cellWidth : 150 * slider.value + 10

                    keyNavigationWraps : true

                    delegate : AlbumListViewDelegate { gridView : listView; width: 150 * slider.value;     height: 150 * slider.value;}
                }
            }
        }
    }
}
