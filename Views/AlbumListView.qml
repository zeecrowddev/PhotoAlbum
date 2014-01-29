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

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0

import ZcClient 1.0 as Zc


import "Tools.js" as Tools


Item
{

    anchors.fill: parent


    function setModel(model)
    {
        repeater.model = model
    }

    signal clean();

    Slider
    {
        id              : slider
        anchors.top     : parent.top
        anchors.left    : parent.left
        anchors.right   : parent.right

        height: 30

        value : 1

        maximumValue: 2
        minimumValue: 0.5
        stepSize: 0.1

        orientation : Qt.Horizontal
    }


    ScrollView
    {
        id : fodlerGridIconeViewId

        anchors.top: slider.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom




        Flow
        {
            id : listView
            anchors.top  : parent.top
            anchors.left : parent.left

            width : slider.width

            flow : Flow.LeftToRight

            spacing: 10

            Repeater {
                id : repeater


                Item
                {

                    width: 200 * slider.value
                    height: 200 * slider.value


                    Rectangle
                    {
                        anchors.fill: parent
                        color : "lightgrey"
                        opacity: 0.5
                    }

                    Image
                    {
                        id : image
                        anchors.top: parent.top
                        anchors.left: parent.left

                        asynchronous: true

                        width : parent.width
                        height : 200 * slider.value - 20

                        fillMode: Image.PreserveAspectFit

                        Component.onCompleted:
                        {
                            refreshImage();
                        }


                        MouseArea
                        {
                            anchors.fill: parent

                            onClicked:
                            {
                                if (!item.cast.isBusy)
                                {
                                    mainView.openFile(item)
                                }
                            }
                        }


                        function refreshImage()
                        {
                            image.source = "";
//                            image.source = documentFolder.getUrl(item.cast);

//                            if (item.status === "" ||item.status === null || item.status === "upload")
//                            {
                                source = "image://tiles/" + "file:///" + documentFolder.localPath + item.cast.name
//                            }
//                            else
//                            {
//                                source = "image://tiles/" + "file:///" + item.cast.name
//                            }
                        }

                        onStatusChanged:
                        {
                            if (status == Image.Error)
                            {
                                extension.text = item.cast.suffix();
                            }
//                            else
//                            {
//                                if (sourceSize.width < parent.width && sourceSize.height < parent.height)
//                                {
//                                    image.width = sourceSize.width;
//                                    image.height = sourceSize.height;

//                                    image.anchors.centerIn = parent;
//                                }

//                            }

                        }

                    }

                    Image
                    {
                        height      : 25
                        width       : 25

                        anchors.bottom: image.bottom
                        anchors.right: parent.right
                        anchors.leftMargin: 3
                        anchors.rightMargin: 3

                        visible    : item.status !== "" && !item.busy
                        source : item.status === "upload" ? "qrc:/PhotoAlbum/Resources/updateUp.png" : "qrc:/PhotoAlbum/Resources/updateDown.png"

                        MouseArea
                        {
                            anchors.fill: parent
                            enabled     : parent.visible

                            onClicked:
                            {
                                mainView.synchronize(item)
                            }
                        }

                    }

                    Rectangle
                    {
                        anchors.verticalCenter: image.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        visible : image.status == Image.Loading
                        color   : "blue"
                        opacity: 0.5

                        height : 20
                        width  : (image.width - 10) * image.progress

                    }

                    Rectangle
                    {
                        anchors.verticalCenter: image.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 5

                        visible : item.queryProgress > 0
                        color   : "green"
                        opacity: 0.5

                        height : 20
                        width  : (image.width - 10) * item.queryProgress / 100


                        onVisibleChanged:
                        {
                            if (visible === false)
                            {
                                image.refreshImage();
                            }
                        }
                    }

                    Rectangle
                    {
                        width : parent.width
                        height: 20

                        anchors.left : parent.left
                        anchors.top : image.bottom

                        color : "lightgrey"
                        opacity: 0.5

                        Label
                        {
                            anchors.fill: parent

                            font.pixelSize: 16
                            text : model.name
                            elide : Text.ElideRight

                            horizontalAlignment: Text.AlignHCenter

                        }
                    }

                    Label
                    {
                        id : extension
                        width : parent.width
                        anchors.centerIn: parent
                        font.pixelSize: 25
                        text : model.name
                        elide : Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter

                        visible: image.status === Image.Error
                    }


                    //        CheckBox
                    //        {
                    //            id : checkBox
                    //            anchors.left: parent.left
                    //            anchors.top: parent.top
                    //            anchors.leftMargin: 3
                    //            anchors.rightMargin: 3

                    //            enabled : !item.busy

                    //            onCheckedChanged:
                    //            {
                    //                model.cast.isSelected = checked
                    //            }

                    //            Component.onCompleted :
                    //            {
                    //                checked = model.cast.isSelected;
                    //            }
                    //        }
                }

            }

        }
    }

}
