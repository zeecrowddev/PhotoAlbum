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

.pragma library

function forEachInObjectList(objectList, delegate)
{
    for (var i=0;i<objectList.count;i++)
    {
        delegate(objectList.at(i));
    }
}

function forEachInArray(array, delegate)
{
    for (var i=0;i<array.length;i++)
    {
        delegate(array[i]);
    }
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
