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

Qt.include("Tools.js")

var instance = {}

instance.fileStatus = {}

instance.fileDescriptorToUpload = {};
instance.fileDescriptorToDownload = {};

var maxNbrDomwnload = 5;
var maxNbrUpload = 5;

var uploadRunning = 0;
var downloadRunning = 0;

var filesToDownload = []
var filesToUpload = []

function nextDownload()
{
    if (filesToDownload.length > 0)
    {
        instance.incrementDownloadRunning()

        var file = filesToDownload.pop();
        setPropertyinListModel(uploadingDownloadingFiles,"status","Downloading",
                               function (x) {
                                   return x.name === file.descriptor.name }
                               );

        documentFolder.downloadFileTo(file.descriptor.cast,file.path)
    }
}

function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        instance.incrementUploadRunning();

        var file = filesToUpload.pop();


        if (file.path !== "" && file.path !== null && file.path !== undefined)
        {
            documentFolder.importImageToLocalFolder(file.descriptor,file.path,1024,1024,"",".upload")
        }
        else
        {
            setPropertyinListModel(uploadingDownloadingFiles,"status","Uploading",function (x) { return x.name === file.descriptor.name });
            documentFolder.uploadFile(file.descriptor,".upload/" + file.descriptor.name)
        }
    }
}

instance.incrementUploadRunning = function()
{
    uploadRunning = uploadRunning + 1
}

instance.decrementUploadRunning = function()
{
    uploadRunning = uploadRunning - 1
}

instance.incrementDownloadRunning = function()
{
    downloadRunning = downloadRunning + 1
}

instance.decrementDownloadRunning = function()
{
    downloadRunning = downloadRunning - 1
}


instance.startDownload = function(file,path)
{
    var fd = {}
    fd.descriptor = file;
    fd.path = path

    filesToDownload.push(fd)

    /*
    ** uploadingFiles contain all progress ulpoading files
    */
    if ( instance.fileDescriptorToDownload[file.name] === null || instance.fileDescriptorToDownload[file.name] === undefined)
    {
        instance.fileDescriptorToDownload[file.name] = file

        /*
        ** to now the state of the progress
        */
        file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });
    }


    var found = findInListModel(uploadingDownloadingFiles, function(x) {return x.name === file.name} )

    if (found === null)
    {
        uploadingDownloadingFiles.append( { "name"  : file.name,
                                 "action" : "Download",
                                 "progress" : 0,
                                 "status" : "Waiting",
                                 "message" : "",
                                 "localPath" : path,
                                  "validated" : false
                          })
    }

    if (downloadRunning < maxNbrDomwnload)
    {
        nextDownload();
    }
}


instance.startUpload = function(file,path)
{
    var fd = {}
    fd.descriptor = file;
    fd.path = path

    filesToUpload.push(fd)

    /*
    ** uploadingFiles contain all progress ulpoading files
    */
    if ( instance.fileDescriptorToUpload[file.name] === null || instance.fileDescriptorToUpload[file.name] === undefined)
    {
        instance.fileDescriptorToUpload[file.name] = file

        /*
        ** to now the state of the progress
        */
        file.queryProgressChanged.connect(function(){ updateQueryProgress(file.queryProgress,file.name) });
    }

    var found = findInListModel(uploadingDownloadingFiles, function(x) {return x.name === file.name} )

    if (found === null)
    {
        uploadingDownloadingFiles.append( { "name"  : file.name,
                                 "action" : "Upload",
                                 "progress" : 0,
                                 "status" : "Waiting",
                                 "message" : "",
                                 "localPath" : path,
                                  "validated" : false
                          })
    }
    else
    {
        setPropertyinListModel(uploadingDownloadingFiles,"localPath",path,function (x) { return x.name === file.name });

        // TO DO : check override filename
    }

    if (uploadRunning < maxNbrUpload)
    {
        nextUpload();
    }
}

function updateQueryProgress(progress, fileName)
{
    setPropertyinListModel(uploadingDownloadingFiles,"progress",progress,function (x) { return x.name === fileName });
}



/*
** Upload is finished
** clean all object and try to do an next upload
*/
instance.uploadFinished = function(fileName,notify)
{
    var fileDescriptor = instance.fileDescriptorToUpload[fileName];

    if (fileDescriptor !== null && fileDescriptor !== undefined)
    {
        documentFolder.removeLocalFile(".upload/" + fileDescriptor.name)
        /*
        ** For example if it's a cancel : no notification for all users
        */
        if (notify)
            notifySender.sendMessage("","{ \"sender\" : \"" + mainView.context.nickname + "\", \"action\" : \"added\" , \"fileName\" : \"" + fileName + "\" , \"size\" : " +  fileDescriptor.size + " , \"lastModified\" : \"" + fileDescriptor.timeStamp + "\" }");
    }
    instance.fileDescriptorToUpload[fileName] = null
    removeInListModel(uploadingDownloadingFiles,function (x) { return x.name === fileName} );
    instance.decrementUploadRunning();
    nextUpload();
}

instance.downloadFinished = function(fileName)
{
    var fileDescriptor = instance.fileDescriptorToDownload[fileName];
    instance.fileDescriptorToDownload[fileName] = null
    removeInListModel(uploadingDownloadingFiles,function (x) { return x.name === fileName} );
    instance.decrementDownloadRunning();
    nextDownload();
}

