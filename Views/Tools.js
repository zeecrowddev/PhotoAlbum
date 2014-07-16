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

.pragma library

function forEachInObjectList(objectList, delegate)
{
    for (var i=0;i<objectList.count;i++)
    {
        delegate(objectList.at(i));
    }
}

function forEachInListModel(listModel, delegate)
{
    for (var i=0;i<listModel.count;i++)
    {
       delegate(listModel.get(i))
    }

    return null;
}

function forEachInArray(array, delegate)
{
    for (var i=0;i<array.length;i++)
    {
        delegate(array[i]);
    }
}

function forEachInverseInArray(array, delegate)
{
    for (var i=array.length - 1 ; i >= 0;i--)
    {
        delegate(array[i]);
    }
}

function findInObjectList(objectList, delegate)
{
    for (var i=0;i<objectList.count;i++)
    {
        if (delegate(objectList.at(i)))
            return objectList.at(i);
    }

    return null;
}


function findInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return listModel.get(i);
    }

    return null;
}

function findInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return listModel.get(i);
    }

    return null;
}

function getIndexInListModel(listModel, findDelegate)
{
    for (var i=0;i<listModel.count;i++)
    {
        if ( findDelegate(listModel.get(i)) )
            return i;
    }
    return -1;
}

function removeInListModel(listModel, findDelegate)
{
    var index = getIndexInListModel(listModel, findDelegate);
    if (index === -1)
        return
    listModel.remove(index)
}





function setPropertyinListModel(listModel, prop , value,  findDelegate)
{
    var index = getIndexInListModel(listModel, findDelegate);
    if (index === -1)
        return
    listModel.setProperty(index,prop,value)
}


function parseDatas(datas)
{
    if (datas === null || datas === undefined)
        return {}


    var objectDatas = null;

    try
    {

        objectDatas = JSON.parse(datas);
    }
    catch (e)
    {
        objectDatas = {}
    }

    if (objectDatas === null)
        return {};

    if (objectDatas === undefined)
        return {};

    objectDatas.testparse = "testparse"
    if (objectDatas.testparse !== "testparse")
    {
        return {}
    }

    objectDatas.testparse = undefined;

    return objectDatas;

}
