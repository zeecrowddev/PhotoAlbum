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

import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1


import "./Delegates"


import "Tools.js" as Tools
import "Main.js" as Presenter

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

    participantMenuActions : [
        Action {
            id: test
            shortcut: "Ctrl+I"
            iconSource: "qrc:/PhotoAlbum/Resources/follow.png"
            tooltip : "Put pictures on the cloud"
            onTriggered:
            {
                loader.item.state = "Following"
                loader.item.followingNickname = source.nickName;

                loader.item.iconFollowingNickname = activity.getParticipantImageUrl(source.nickName)

                var source = participantPreview.getItem(source.nickName,"");
                loader.item.setCurrentIndex(source);
            }
        }
    ]


    toolBarActions : [
        Action {
            id: closeAction
            shortcut: "Ctrl+X"
            iconSource: "qrc:/PhotoAlbum/Resources/close.png"
            tooltip : "Close Aplication"
            onTriggered:
            {
                mainView.close();
            }
        }
        ,
        Action {
            id: importAction
            shortcut: "Ctrl+I"
            iconSource: "qrc:/PhotoAlbum/Resources/export.png"
            tooltip : "Put pictures on the cloud"
            onTriggered:
            {
                mainView.state = "putOnCloud"
                fileDialog.selectMultiple = true;
                fileDialog.nameFilters = [ "Image files (*.jpg *.png *.gif *.png *.tiff)", "All files (*)" ]
                fileDialog.selectFolder = false
                fileDialog.open()
            }
        }
        ,
        Action {
            id: deleteAction
            shortcut: "Ctrl+D"
            iconSource: "qrc:/PhotoAlbum/Resources/bin.png"
            tooltip : "Delete File"
            onTriggered:
            {
                mainView.deleteSelectedFiles();
            }
        }
        ,
        Action {
            id: exportAction
            shortcut: "Ctrl+E"
            iconSource: "qrc:/PhotoAlbum/Resources/import.png"
            tooltip : "Download pictures"
            onTriggered:
            {
                mainView.state = "putOnLocalDrive"
                fileDialog.selectMultiple = false;
                fileDialog.nameFilters = ""
                fileDialog.selectFolder = true
                fileDialog.open()
            }
        }
    ]


    Zc.AppNotification
    {
        id : appNotification
    }

    onIsCurrentViewChanged :
    {
        if (isCurrentView == true)
        {
            appNotification.resetNotification();
        }
    }

    function loadComments(url)
    {

        // on ne sait jamais on cancel al requete précedente
        getSharedResourceQueryStatus.cancel()

        var name = sharedResource.getNameFromUrl(url)

        getSharedResourceQueryStatus.content = url;

        sharedResource.getText("comments/" + name  + "_txt",getSharedResourceQueryStatus);
    }

    function putComments(url,comment)
    {

        if (comment === "" || comment === null || comment === undefined)
            return;

        var result = {};
        result.datas = [];


        Tools.forEachInListModel(currentComments, function (x)
        {  var elm = {}
            elm.comment = x.comment
            elm.who = x.who
            elm.date = x.date
            result.datas.push(elm);
        })


        var newElm = {}
        newElm.who = mainView.context.nickname
        newElm.comment = comment

        newElm.date = new Date().getTime()
        result.datas.unshift(newElm);
        var toPut = JSON.stringify(result);

        newElm.url = url.toString()
        var toNotify = JSON.stringify(newElm)

        var name = sharedResource.getNameFromUrl(url)

        putSharedResourceQueryStatus.content = toNotify

        putSharedResourceQueryStatus.url = url
                putSharedResourceQueryStatus.newComment = comment;

        sharedResource.putText("comments/" + name + "_txt",toPut,putSharedResourceQueryStatus);
    }


    Zc.CrowdActivity
    {
        id : activity

        /*
        ** Pouyr pouvoire suivre ce que visualize un autre participant
        */
        Zc.CrowdActivityItems
        {
            id         : participantPreview
            name       : "ParticipantPreview"
            persistent : false

            onItemChanged :
            {
                if (loader.item.state !== "Following")
                    return;

                if (loader.item.followingNickname !== idItem)
                    return;

                var source = participantPreview.getItem(idItem,"");


                loader.item.setCurrentIndex(source);
            }

        }

        /*
        ** Nombre de commetaires par image
        */
        Zc.CrowdActivityItems
        {
            id         : nbrComments
            name       : "NumberComments"
            persistent : true

            Zc.QueryStatus
            {
                id : nbrCommentsQueryStatus

                onCompleted :
                {

                    Tools.forEachInObjectList(documentFolder.files,function (x)
                    {
                        var value = nbrComments.getItem(x.name,"");
                        if (value !== "")
                        {
                            x.cast.datas = value
                        }

                    });
                }
            }

            onItemChanged :
            {
                var value = nbrComments.getItem(idItem,"");

                var find = Tools.findInObjectList(documentFolder.files, function(x) { return x.name === idItem});

                if (find !==null)
                {
                    find.cast.datas = value
                }
            }

        }

        /*
        ** Notification d'ajout ou suppression d'images
        */
        Zc.MessageListener
        {
            id      : notifyListener
            subject : "notify"

            onMessageReceived :
            {
                var o = JSON.parse(message.body);

                if ( o !==null )
                {

                    appNotification.blink();
                    if (!mainView.isCurrentView)
                    {
                        appNotification.incrementNotification();
                    }

                    if ( o.action === "deleted" )
                    {
                        documentFolder.removeFileDescriptor(o.fileName)
                    }
                    else if (o.action === "added")
                    {
                        var fd = documentFolder.getFileDescriptor(o.fileName,true);
                        fd.setRemoteInfo(o.size,new Date(o.lastModified));
                        fd.status = "download";
                    }
                }

            }
        }

        Zc.MessageSender
        {
            id      : notifySender
            subject : "notify"
        }

        /*
        ** Notifiation des commentaires
        */

        Zc.MessageSender
        {
            id      : senderCommentNotify
            subject : "Comment"
        }

        Zc.MessageListener
        {
            id      : listenerCommentNotify
            subject : "Comment"

            onMessageReceived :
            {
                var o = Tools.parseDatas(message.body);

                if ( o.url !==null && o.url !== undefined )
                {
                    appNotification.blink();
                    if (!mainView.isCurrentView)
                    {
                        appNotification.incrementNotification();
                    }

                    // pour l'instant on refait un Get ...
                    // a optimiser ..
                    if (o.url === loader.item.getPreviewSource())
                    {
                        loadComments(o.url)
                    }
                }
            }
        }

        /*
        ** Recuperation des commentaires
        */
        Zc.CrowdSharedResource
        {
            id   : sharedResource
            name : "Comments"


            Zc.StorageQueryStatus
            {
                id : getSharedResourceQueryStatus

                onErrorOccured :
                {
                }

                onCompleted :
                {
                    if (sender.content === null || sender.content === undefined || sender.content !== loader.item.getPreviewSource())
                    {
                        return;
                    }


                    var result = Tools.parseDatas(sender.text);

                    currentComments.clear();

                    if (result.datas !== null && result.datas !== undefined)
                    {
                        Tools.forEachInArray(result.datas , function (x) {

                            if (x.comment === null || x.comment === undefined)
                            {
                                x.comment = ""
                            }

                            if (x.date === null || x.date === undefined || x.date === "")
                            {
                                x.date = 0;
                            }

                            currentComments.append({ "who" : x.who, "comment" : x.comment, "date" : x.date })});

                        // voiture balai qui met le compteur à jour
                        var name = sharedResource.getNameFromUrl(sender.content)
                        nbrComments.setItem(name,result.datas.length);
                    }

                }
            }

            Zc.StorageQueryStatus
            {
                id : putSharedResourceQueryStatus

                property string newComment : ""
                property string url : ""

                onErrorOccured :
                {
                    loader.item.stopWaiting();
                }

                onCompleted :
                {
                    loader.item.stopWaiting();

                    var toNotify = sender.content;
                    senderCommentNotify.sendMessage("",toNotify)

                    appNotification.logEvent(Zc.AppNotification.Add,"Photo Comment",newComment,url)

                    // Apres avoir pushé le nouveau commentaire on
                    // met le compteur d emessages à jour
                    if (toNotify.url !== null && toNotify.url !== undefined || toNotify.url !== "")
                    {
                        var name = sharedResource.getNameFromUrl(url)
                        nbrItem.setItem(name,result.datas.length);
                    }



                }

            }
        }

        /*
        ** les photos
        */
        Zc.CrowdDocumentFolder
        {
            id   : documentFolder
            name : "Images"
            
            Zc.QueryStatus
            {
                id : documentFolderQueryStatus

                onErrorOccured :
                {
                    console.log(">> ERRROR OCCURED")
                }

                onCompleted :
                {
                    loader.item.setModel(documentFolder.files);

                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;

                    // recupération du nombre de commentaires
                    nbrComments.loadItems(nbrCommentsQueryStatus)
                }
            }

            onImportFileToLocalFolderCompleted :
            {
                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {
                    var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];

                    Tools.setPropertyinListModel(uploadingDownloadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                    Presenter.instance.decrementUploadRunning();
                    Presenter.instance.startUpload(fileDescriptor,"");
                    return;
                }
            }

            onFileUploaded :
            {

                appNotification.logEvent(Zc.AppNotification.Add,"Photo","",documentFolder.getUrlFromFileName(fileName))

                Presenter.instance.uploadFinished(fileName,true);

                // close the upload view
                closeUploadViewIfNeeded()
            }

            onFileDownloaded :
            {
                Presenter.instance.downloadFinished(fileName);
                // close the upload view
                closeUploadViewIfNeeded()
            }

            onFileDeleted :
            {
                notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\"}");
            }
        }


        /*
        ** Le chat
        */
        Zc.ChatMessageSender
        {
            id      : senderChat
            subject : "Chat"
        }

        Zc.ChatMessageListener
        {
            id      : listenerChat

            subject : "Chat"

            allowGrouping : false

            onMessageChangedOrAdded :
            {
                appNotification.blink();
            }
        }

        onStarted:
        {
            participantPreview.loadItems();
            documentFolder.ensureLocalPathExists();
            documentFolder.ensureLocalPathExists(".upload/");
            documentFolder.loadRemoteFiles(documentFolderQueryStatus);
        }
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }

    ListModel
    {
        id : uploadingDownloadingFiles
    }

    property alias currentCommentsListModel : currentComments

    ListModel
    {
        id : currentComments
    }

    function setPreviewSource(source)
    {
        loader.item.setPreviewSource(source)
    }

    function closeUploadViewIfNeeded()
    {
        if (uploadingDownloadingFiles.count === 0)
        {
            loaderUploadView.height = 0
        }
    }

    function openUploadView()
    {
        if (loaderUploadView.height === 0)
        {
            loaderUploadView.height = 200
        }
    }

    Component
    {
        id : handleDelegateVertical

        Rectangle
        {
            height : 3
            color :  styleData.hovered ? "grey" :  "lightgrey"

            Rectangle
            {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                height : 1
                color :  "grey"
            }
        }
    }

    Component
    {
        id : handleDelegateHorizontal

        Item
        {
            width : 15

            Rectangle
            {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                width : 3
                color :  styleData.hovered ? "grey" :  "lightgrey"

                Rectangle
                {
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    width : 1
                    color :  "grey"
                }

                Rectangle
                {
                    anchors.centerIn : parent
                    width : 15
                    height : 15
                    radius : 2
                    color :  "lightgrey"
                    border.color: "black"
                    border.width: 1
                    opacity : 0.5
                }
            }
        }
    }

    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical


        handleDelegate : handleDelegateVertical

        Loader
        {
            id : loader
            source : "AlbumListView.qml"

            Rectangle
            {
                anchors.fill: parent
                color : "white"
            }

            Layout.fillWidth : true
            Layout.fillHeight : true
        }



        Loader
        {
            id : loaderUploadView
            height : 0

            source : "UploadStatusView.qml"

            onSourceChanged:
            {
                item.setModel(uploadingDownloadingFiles);
            }
        }
    }

    function putFilesOnTheCloud(fileUrls)
    {
        openUploadView()

        var fds = [];


        for ( var i = 0 ; i < fileUrls.length ; i ++)
        {
            var fd = documentFolder.createFileDescriptorFromFile(fileUrls[i]);


            if (fd !== null)
            {
                var fdo = {}
                fdo.fileDescriptor =fd;
                fdo.url = fileUrls[i];
                fds.push(fdo);
                fd.queryProgress = 1;
            }
        }

        Tools.forEachInArray(fds, function (x)
        {
            Presenter.instance.startUpload(x.fileDescriptor.cast,x.url);
        });
    }

    function putFilesOnLocalDrive(folder)
    {
        openUploadView()

        Tools.forEachInObjectList( documentFolder.files, function(x)
        {
            if (x.cast.isSelected)
            {
                Presenter.instance.startDownload(x.cast,folder);
            }
        })

    }


    FileDialog
    {
        id: fileDialog
        nameFilters: state === "putOnCloud" ? [ "Image files (*.jpg *.png *.gif *.png *.tiff)", "All files (*)" ] : ""
        selectFolder: state === "putOnLocalDrive" ? true : false

        onAccepted:
        {
            if ( state === "putOnCloud" )
            {
                putFilesOnTheCloud(fileDialog.fileUrls);
            }
            else if (state === "putOnLocalDrive")
            {
                putFilesOnLocalDrive(fileDialog.folder);
            }
        }
    }

    onLoaded :
    {
        activity.start();
    }

    onClosed :
    {
        participantPreview.removeItem(mainView.context.nickname);
        activity.stop();
    }

    function importFile(fileUrls)
    {
        var fds = [];
        for ( var i = 0 ; i < fileUrls.length ; i ++)
        {
            var fd = documentFolder.addFileDescriptorFromFile(fileUrls[i]);
            if (fd !== null)
            {
                var fdo = {}
                fdo.fileDescriptor =fd;
                fdo.url = fileUrls[i];
                fds.push(fdo);
                fd.queryProgress = 1;
            }
        }

        Tools.forEachInArray(fds, function (x)
        {
            Presenter.instance.startUpload(x.fileDescriptor,x.url);
        });
    }

    function exportFile()
    {
        Tools.forEachInObjectList( documentFolder.files, function(x)
        {
            if (x.cast.isSelected)
            {
                if (x.cast.status !== "")
                {
                    x.queryProgress = 1;
                    Presenter.instance.startDownload(x.cast);
                    //documentFolder.downloadFile(x.cast)
                }
            }
        })
    }

    function deleteSelectedFiles()
    {
        Tools.forEachInObjectList( documentFolder.files, function(file)
        {
            if (file.cast.isSelected)
            {
                documentFolder.deleteFile(file);
                sharedResource.deleteFile("comments/" + file.name + "_txt",null)
                nbrComments.deleteItem(file.name);
            }
        })
    }

    function refreshFiles()
    {
        //documentFolder.clearFiles();
        //documentFolder.loadFiles();
    }

    function synchronize(file)
    {
        if (file.status === "upload")
        {
            Presenter.instance.startUpload(file,"");
        }
        else if (file.status === "download")
        {
            Presenter.instance.startDownload(file);
        }

    }
}
