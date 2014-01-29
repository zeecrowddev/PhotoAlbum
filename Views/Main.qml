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
            iconSource: "qrc:/PhotoAlbum/Resources/import.png"
            tooltip : "Import File"
            onTriggered:
            {
                mainView.state = "import"
                fileDialog.selectMultiple = true;
                fileDialog.selectFolder = false
                fileDialog.open()
            }
        }
       ,
        Action {
            id: exportAction
            shortcut: "Ctrl+E"
            iconSource: "qrc:/PhotoAlbum/Resources/export.png"
            tooltip : "Export File"
            onTriggered:
            {
                mainView.state = "export"
                exportFile();
                documentFolder.openLocalPath();
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
//        ,
//        Action {
//            id: refreshAction
//            shortcut: "F5"
//            iconSource: "qrc:/PhotoAlbum/Resources/updates.png"
//            tooltip : "Synchronize all\nselected files"
//            onTriggered:
//            {
//            //    mainView.synchronizeSelectedFiles();
//            }
//        }
        ,
        Action {
            id: iconAction
            iconSource: "qrc:/PhotoAlbum/Resources/tile.png"
            onTriggered:
            {
//               loader.item.clean()
//               loader.source = "";
//               loader.source = "FolderGridIconView.qml"
//               loader.item.setModel(documentFolder.files);
            }
        }
    ]

    Zc.CrowdActivity
    {
        id : activity

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


                    loader.item.setModel(documentFolder.files);
                    splashScreenId.height = 0;
                    splashScreenId.width = 0;
                    splashScreenId.visible = false;
                }
            }

            onImportFileToLocalFolderCompleted :
            {
                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});

                if (result === null || result === undefined)
                    return;

                documentFolder.uploadFile(result);
            }

            onFileUploaded :
            {
                Presenter.instance.uploadFinished();

                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});


                if (result === null || result === undefined)
                    return;

                notifySender.sendMessage("","{ sender : \"" + mainView.context.nickname + "\", action : \"added\" , fileName : \"" + fileName + "\" , size : " +  result.size + " , lastModified : \"" + result.timeStamp + "\" }");
             }

            onFileDownloaded :
            {
                Presenter.instance.downloadFinished();
                var result = Tools.findInListModel(documentFolder.files, function(x)
                {return x.cast.name === fileName});

                if (result === null || result === undefined)
                    return;

                if (Presenter.instance.fileStatus[result.cast.name] === "open")
                {
                    Presenter.instance.fileStatus[result.cast.name] = null;
                    documentFolder.openFileWithDefaultApplication(result.cast);
                }
            }
            onFileDeleted :
            {
                notifySender.sendMessage("","{ sender : \"" + mainView.context.nickname + "\", action : \"deleted\" , fileName : \"" + fileName + "\"}");
            }

        }

        onStarted:
        {
            documentFolder.ensureLocalPathExists();
            documentFolder.ensureLocalPathExists(".Thumb/");
            documentFolder.loadRemoteFiles(documentFolderQueryStatus);
       //     folderGridView.setModel(documentFolder.files);
        }
    }

    SplashScreen
    {
        id : splashScreenId
        width : parent.width
        height: parent.height
    }

    Loader
    {
        id : loader
        anchors.fill : parent
        source : "AlbumListView.qml"
    }


    FileDialog
    {
        id: fileDialog
        nameFilters: [ "Image files (*.jpg *.png *.gif *.png *.tiff)", "All files (*)" ]
        onAccepted:
        {
            if ( state == "import" )
            {
                importFile(fileDialog.fileUrls);
            }
//            else
//            {
//                exportFile(fileDialog.folder);
//            }
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


}
