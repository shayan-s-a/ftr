
export const log = (msg, obj) => {
    if (!obj || obj instanceof String) {
        console.log(msg, obj);
    } else if (obj instanceof Error) {
        console.error(msg, obj);
    } else {
        console.log(msg, JSON.parse(JSON.stringify(obj)));
    }
};

export const convertToSpeed = (bandWidth) => {
    if (!bandWidth) return null;
    if (bandWidth.toUpperCase().includes('MB')) {
        return parseInt(bandWidth.replace(/[^\d]/g, '').trim());
    } else if (bandWidth.toUpperCase().includes('GB')) {
        return parseInt(bandWidth.replace(/[^\d]/g, '').trim()) * 1000;
    } else {
        return 0;
    }
};

export const getOmniMergeFields = (omniJsonData, str) => {
    if (str && str.split('%').length > 0) {
        for (let mergeField of str.split('%').filter((val, index) => index % 2 !== 0)) {
            str = str.replace(mergeField, getOmniMergeField(omniJsonData, mergeField));
        }
        str = str.replaceAll('%', '\"');
    }
    return str;
};

export const getOmniMergeField = (omniJsonData, path) => {
    let value = '';
    if (path) {
        let pathList = path.split(':');
        if (omniJsonData[pathList[0]])
            value = omniJsonData[pathList[0]];
        if (pathList.length > 1) {
            pathList.splice(0, 1);
            pathList.forEach(obj => {
                if (value[obj]) value = value[obj];
            });
        }
    }
    return value;
};