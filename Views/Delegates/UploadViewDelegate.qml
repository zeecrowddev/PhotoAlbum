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

import "../Tools.js" as Tools

Rectangle
{
    height : 20
    width : parent.width
    color : index % 2 ? "lightgrey" : "white"

    Row
    {
        anchors.fill: parent
        Label
        {
            id :lbStatus
            height : 20 ;
            width : 200 ;
            text: status ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            id : lbName
            height : 20 ;
            width : 200 ;

            text: name ;
            color : "black";
            font.pixelSize:  16
        }

        Label
        {
            height : 20 ;

            width  : 400

            text: message ;
            color : "black";
            font.pixelSize:  16
        }

//        Button
//        {
//            height : 20 ;
//            width  : status === "NeedValidation" ? 80 : 0
//            text: "Validate"

//            onClicked:
//            {
//                Tools.setPropertyinListModel(uploadingFiles,"status","Validated",function (x) { return x.name === name });
//                Tools.setPropertyinListModel(uploadingFiles,"validated",true,function (x) { return x.name === name });
//                Tools.setPropertyinListModel(uploadingFiles,"message","",function (x) { return x.name === name });
//                mainView.restartUpload(name,localPath);
//            }
//        }
        Button
        {
            height : 20 ;
            width  : 80
            text: "Cancel"

            onClicked:
            {
                mainView.cancelUpload(name);
            }
        }
    }

    ProgressBar
    {
        anchors.fill: parent
        visible : progress > 0
        opacity: 0.5

        height : parent.height
        width  : parent.width

        minimumValue: 0
        maximumValue: 100
        value       : progress
    }

}
