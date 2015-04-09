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
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2

import ZcClient 1.0 as Zc

import "./Delegates"
import "Tools.js" as Tools


Item
{
    id : albumListView

    focus : true

    anchors.fill: parent

    state : "Consultation"
    property string followingNickname : ""
    property string iconFollowingNickname : ""


    function showCamera()
    {
        cameraPreview.visible = true;
        cameraPreview.source = "CameraView.qml";
        cameraPreview.item.localPath = mainView.localPath
        cameraPreview.item.close.connect( function (x) {
        cameraPreview.source = "";
        cameraPreview.visible = false; })
        cameraPreview.item.sendCameraPicture.connect(function (x)
        {
            cameraPreview.source = ""
            cameraPreview.visible = false;

            if (x !== "")
            {
               mainView.uploadFile(x)
            }

        } );

    }

    function stopWaiting()
    {
        commentsView.state = "comments"
    }

    function setModel(model)
    {
        listView.model = model
    }


    function getPreviewSource()
    {
        return preview.source.toString();
    }

    function setPreviewSource(source)
    {
        preview.source = source;
    }

    function setCurrentIndex(source)
    {
        var index = Tools.getIndexInListModel(documentFolder.files, function (x){
            return documentFolder.getUrl(x.cast) === source;
        });

        if (index === -1)
            return;

        if (listView.model === null)
            return;

        if (index >= listView.model.count)
            return;

        listView.currentIndex = index;
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

        SplitView
        {
            orientation: Qt.Horizontal

            handleDelegate : handleDelegateHorizontal

            id : previewItem

            height: 0

            Item
            {
                id : commentsView

                width : parent.width / 4

                state : "comments"

                ToolBar
                {
                    id : toolBarComments
                    style: ToolBarStyle {}

                    RowLayout
                    {
                        ToolButton
                        {

                            visible : commentsView.state == "comments" ? true : false

                            action : Action
                            {
                            id : addComment
                            iconSource  : "qrc:/PhotoAlbum/Resources/plus.png"
                            tooltip     : "Add a comment"
                            onTriggered :
                            {

                                commentsView.state = "addComments"
                                textAreaComment.focus = true
                                textAreaComment.forceActiveFocus();
                                textAreaComment.text = ""
                            }
                        }
                    }
                    ToolButton
                    {
                        visible : commentsView.state == "comments" ? false : true

                        action : Action
                        {
                        id : validateComment
                        iconSource  : "qrc:/PhotoAlbum/Resources/ok.png"
                        tooltip     : "Validate the comment"
                        onTriggered :
                        {
                            textAreaComment.focus = false;

                            if (textAreaComment.text !== "" && textAreaComment.text !== null && textAreaComment.text !== undefined)
                            {
                                commentsView.state = "uploading"
                                mainView.putComments(preview.source, textAreaComment.text);
                            }
                            else
                            {
                                commentsView.state = "comments"
                            }
                        }
                    }
                }
                ToolButton
                {
                    visible : commentsView.state == "comments" ? false : true

                    action : Action
                    {
                    id : cancelComment
                    iconSource  : "qrc:/PhotoAlbum/Resources/cancel.png"
                    tooltip     : "Cancel the comment"
                    onTriggered :
                    {
                        textAreaComment.focus = false;
                        commentsView.state = "comments"
                    }
                }
            }

            Label
            {
                height : parent.height

                text : "Comments"

                font.pixelSize: 20

                visible : commentsView.state == "comments" ? true : false
            }

        }
    }

    TextArea
    {
        id : textAreaComment
        anchors
        {
            top : toolBarComments.bottom
            topMargin : 5
            horizontalCenter : parent.horizontalCenter
        }

        style : TextAreaStyle {  transientScrollBars : false; backgroundColor: Qt.lighter("#ff6600") }

        width : parent.width - 10

        height : parent.state == "addComments" ? 100 : 0
        visible : parent.state == "addComments"

        wrapMode: TextEdit.WordWrap

    }

    //    Component
    //    {
    //        id : commentDelegate

    //        TextArea
    //        {
    //            style : TextAreaStyle {  transientScrollBars : false  }

    //            //color : "red"
    //            width: parent.width
    //            height : 50

    //            readOnly: true

    //            text : comment

    //            wrapMode: TextEdit.WordWrap
    //        }
    //    }


    // List on comments
    ScrollView
    {
        anchors
        {
            top : textAreaComment.bottom
            topMargin : 5
            left : parent.left
            bottom: parent.bottom
            right: parent.right
        }

        style :  ScrollViewStyle { transientScrollBars : false }

        ListView
        {
            anchors.fill: parent

            delegate:
                CommentDelegate
            {
            contactImageSource : activity.getParticipantImageUrl(model.who)

            Component.onCompleted:
            {
            }
        }

        model : currentCommentsListModel

        spacing: 5
    }

}
Rectangle
{
    anchors.fill: parent
    color : "grey"
    opacity : 0.5

    visible : parent.state == "uploading"


    BusyIndicator
    {
        style : BusyIndicatorStyle {}

        width : 100
        height : 100
        anchors.centerIn: parent
    }


}


}

Item
{


    height : parent.height

    Layout.fillWidth : true
    Layout.fillHeight : true


    Item
    {
        id : imagePreview

        anchors.fill: parent

        Image
        {
            id : preview

            MouseArea
            {
                anchors.fill : parent
                onClicked:
                {
                    inputMessage.focus = false
                }
            }

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
            width : 210
            height : 50
            spacing: 10

            visible: albumListView.state == "Following"

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter

            Button
            {
                id : stopFollow

                width : 50
                height : 50

                style:
                ButtonStyle {
                    background: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30

                        color : control.pressed ? "#EEEEEE" : "#00000000"
                        radius: 4

                        Image
                        {
                            source : "qrc:/PhotoAlbum/Resources/close.png"
                            anchors.fill: parent
                        }
                    }
                }

                onClicked:
                {
                    albumListView.state = "Consultation"
                    albumListView.followingNickname = ""
                }
            }

            Image
            {
                id : followIconUser
                width : 40
                height : 40

                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: stopFollow.verticalCenter

                source : iconFollowingNickname

                onStatusChanged:
                {
                    if (status === Image.Error)
                    {
                        source = "qrc:/Crowd.Core/Qml/Ressources/Pictures/DefaultUser.png"
                    }
                }
            }

            Label
            {
                width : 100
                anchors.verticalCenter: stopFollow.verticalCenter
                text : "Following : " + albumListView.followingNickname
                font.pixelSize: 16
            }


        }

        Row
        {
            width : 110
            height : 50
            spacing: 10

            visible: albumListView.state == "Consultation"

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
                        listView.currentIndex = listView.currentIndex - 1;
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
}


Item
{
    width : parent.width / 4

    ToolBar
    {
        id : toolBarChat

        height : toolBarComments.height
        style: ToolBarStyle
        {
        }

        RowLayout
        {
            anchors.fill: parent

            Label
            {
                height : parent.height

                text : "Chat"

                font.pixelSize: 20
            }
        }
    }


    ScrollView
    {
        id : chatView

        Component.onCompleted:
        {
            chatView.flickableItem.contentY = height
        }

        function goToEnd()
        {

            var cy = chatView.flickableItem.contentY > 0 ? chatView.flickableItem.contentY : 0
            var delta = chatView.flickableItem.contentHeight - (cy + chatView.flickableItem.height);

            if (delta <= 30)
            {
                chatView.flickableItem.contentY = Math.round(column.height - chatView.flickableItem.height);
            }

        }


        anchors.top: toolBarChat.bottom
        anchors.left : parent.left
        anchors.right: parent.right

        height: previewItem.height - 70 - toolBarChat.height


        clip: true

        Column
        {
            id : column


            onHeightChanged :
            {
                chatView.goToEnd();
            }

            spacing: 5

            Repeater
            {
                model : listenerChat.messages
                ChatDelegate
                {
                    width : chatView.flickableItem.width - 5

                    contactImageSource : activity.getParticipantImageUrl(from)
                }
            }
        }

    }

    InputMessageWidget
    {
        id : inputMessage
        height: 60;
        anchors.left : parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        onAccepted:
        {
            if (Qt.platform.os === "android")
            {
                inputMessage.resetFocus()
            }

            senderChat.sendMessage(message)
        }
    }
}

//            Item
//            {
//                id : rightPanel

//                width : 100


//            }

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
            listView.selectedAllChanged(checked);

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

            signal selectedAllChanged(bool val);


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
                var oldSource = preview.source;

                if (currentIndex >= 0)
                {
                    showPreview();
                    preview.source =    documentFolder.getUrl(model.get(currentIndex));

                    mainView.loadComments(preview.source)

                }
                else
                {
                    closePreview();
                    preview.source = "";
                }

                if (oldSource !== preview.source)
                {
                    participantPreview.setItem(mainView.context.nickname,preview.source)
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

            delegate : AlbumListViewDelegate {
                gridView: listView
                width: 150 * slider.value;     height: 150 * slider.value;
                onClicked :
                {
                    if (albumListView.state === "Consultation")
                    listView.currentIndex = index;
                }
            }
        }
    }
}
}

    Loader
    {
        id : cameraPreview

        anchors.fill: parent

        visible : false
    }

}
