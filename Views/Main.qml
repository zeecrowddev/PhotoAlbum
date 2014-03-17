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
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0


import "./Delegates"


import "Tools.js" as Tools
import "Main.js" as Presenter

import ZcClient 1.0 as Zc

Zc.AppView
{
    id : mainView

    anchors.fill : parent

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
                fileDialog.selectFolder = false
                fileDialog.open()
            }
        }
        //        ,
        //        Action {
        //            id: exportAction
        //            shortcut: "Ctrl+E"
        //            iconSource: "qrc:/PhotoAlbum/Resources/folder.png"
        //            tooltip : "Open Local Folder"
        //            onTriggered:
        //            {
        //                documentFolder.openLocalPath();
        //            }
        //        }
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
        ////        ,
        ////        Action {
        ////            id: refreshAction
        ////            shortcut: "F5"
        ////            iconSource: "qrc:/PhotoAlbum/Resources/updates.png"
        ////            tooltip : "Synchronize all\nselected files"
        ////            onTriggered:
        ////            {
        ////            //    mainView.synchronizeSelectedFiles();
        ////            }
        ////        }
        //        ,
        //        Action {
        //            id: iconAction
        //            iconSource: "qrc:/PhotoAlbum/Resources/tile.png"
        //            onTriggered:
        //            {
        ////               loader.item.clean()
        ////               loader.source = "";
        ////               loader.source = "FolderGridIconView.qml"
        ////               loader.item.setModel(documentFolder.files);
        //            }
        //        }
    ]


    Zc.AppNotification
    {
        id : appNotification
    }


    Zc.CrowdActivity
    {
        id : activity

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
                        if (o.sender !== mainView.context.nickname)
                        {
                            documentFolder.removeLocalFile(o.fileName)
                        }
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

        Zc.CrowdDocumentFolder
        {
            id   : documentFolder
            name : "Test"
            
            Zc.QueryStatus
            {
                id : documentFolderQueryStatus

                onErrorOccured :
                {
                    console.log(">> ERRROR OCCURED")
                }

                onCompleted :
                {
                    var toBeDeleted = [];

                    Tools.forEachInObjectList( documentFolder.files, function(file)
                    {

                        if (file.cast.status === "new")
                        {
                            toBeDeleted.push(file.cast.name);
                        }
                    })

                    Tools.forEachInArray(toBeDeleted, function (x)
                    {
                        documentFolder.removeFileDescriptor(x);
                    })


                    console.log(">>>>>> on Completed")

                    loader.item.setModel(documentFolder.files);
                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;
                }
            }

            onImportFileToLocalFolderCompleted :
            {
                // import a file to the .upload directory finished
                if (localFilePath.indexOf(".upload") !== -1)
                {
                    var fileDescriptor = Presenter.instance.fileDescriptorToUpload[fileName];


                    Tools.setPropertyinListModel(uploadingFiles,"status","Uploading",function (x) { return x.name === fileName });
                    Presenter.instance.decrementUploadRunning();
                    Presenter.instance.startUpload(fileDescriptor,"");
                    return;
                }
            }

            onFileUploaded :
            {

                Presenter.instance.uploadFinished(fileName,true);

                // close the upload view
                closeUploadViewIfNeeded()
            }

            //            onFileDownloaded :
            //            {
            //                /*
            //                ** downloadFile to read it or to modify it
            //                */

            //                Presenter.instance.downloadFinished();

            //                if (Presenter.instance.fileStatus[fileName] === "open")
            //                {
            //                   Presenter.instance.fileStatus[fileName] = null
            //                   Qt.openUrlExternally(localFilePath)
            //                }
            //            }

            onFileDeleted :
            {
                notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"deleted\" , \"fileName\" : \"" + fileName + "\"}");
            }
        }

        onStarted:
        {
            console.log(">> onStarted")

            documentFolder.ensureLocalPathExists();
            documentFolder.ensureLocalPathExists(".thumb/");
            documentFolder.ensureLocalPathExists(".upload/");

            console.log(">> documentFolder.loadRemoteFiles(documentFolderQueryStatus);")

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
        id : uploadingFiles
    }


    function setPreviewSource(source)
    {
        loader.item.setPreviewSource(source)
    }

    function closeUploadViewIfNeeded()
    {
        if (uploadingFiles.count === 0)
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


    SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        Component
        {
            id : handleDelegateVertical

            Rectangle
            {
                height : 10
                color :  styleData.hovered ? "grey" :  "lightgrey"

            }
        }


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

            Keys.onPressed:
            {
                console.log(">> key pressed ")
            }


        }



        Loader
        {
            id : loaderUploadView
            height : 0

            source : "UploadStatusView.qml"

            onSourceChanged:
            {
                item.setModel(uploadingFiles);
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


    FileDialog
    {
        id: fileDialog
        nameFilters: [ "Image files (*.jpg *.png *.gif *.png *.tiff)", "All files (*)" ]
        onAccepted:
        {
            if ( state == "putOnCloud" )
            {
                putFilesOnTheCloud(fileDialog.fileUrls);
            }
        }
    }

    onLoaded :
    {
        activity.start();
    }

    onClosed :
    {
        activity.stop();
    }

    //    function openFile(file)
    //    {
    //        documentFolder.openFileWithDefaultApplication(file);
    //    }

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

    Keys.onPressed:
    {
        console.log(">> key pressed ")
    }


}
