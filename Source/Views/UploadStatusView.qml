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
import QtQuick.Controls 1.0

import "./Delegates"

Item
{
    width: 100
    height: 62


    function setModel(model)
    {
        uploadingFilesView.model = model
    }

    ListView
    {
        id : uploadingFilesView

        spacing: 5

        anchors
        {
            top : parent.top
            topMargin : 5
            right : parent.right
            left : parent.left
            bottom : parent.bottom
        }

        delegate: UploadViewDelegate{}
    }
}
