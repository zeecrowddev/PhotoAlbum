var instance = {}

instance.fileStatus = {}

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
        downloadRunning++;
        var file = filesToDownload.pop();
        documentFolder.downloadFile(file.cast)
    }
}

function nextUpload()
{
    if (filesToUpload.length > 0)
    {
        uploadRunning++;
        var file = filesToUpload.pop();


        if (file.path !== "" && file.path !== null && file.path !== undefined)
        {
            documentFolder.importFileToLocalFolder(file.descriptor,file.path)
        }
        else
        {
            documentFolder.uploadFile(file.descriptor)
        }
    }
}

instance.startDownload = function(file)
{
    filesToDownload.push(file)
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
    if (uploadRunning < maxNbrUpload)
    {
        nextUpload();
    }
}

instance.uploadFinished = function()
{
    uploadRunning = uploadRunning - 1;
    nextUpload();
}

instance.downloadFinished = function()
{
    downloadRunning--;
    nextDownload();
}
