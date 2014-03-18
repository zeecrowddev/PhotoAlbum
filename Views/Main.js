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

                                   console.log(">>> search 1 " + x)
                                   console.log(">>> search 2 " + x.name)

                                   return x.name === file.descriptor.name }
                               );

        console.log(">> call downloadFileTo " + file.cast + " "  + file.path)

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
            documentFolder.importFileToLocalFolder(file.descriptor,file.path,".upload")
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
        documentFolder.removeLocalFile(".upload\\" + fileDescriptor.name)
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

