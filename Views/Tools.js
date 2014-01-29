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
