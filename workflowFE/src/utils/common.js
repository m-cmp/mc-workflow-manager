
/* Comment translated to English. */
export function getUserNameAndIdStr(name, id) {
  name = name || ''
  id = id || ''
  return `${name}(@${id})`
}

export function validateGroupName(name) {
  const reg = /^[A-z0-9_-]{1,50}$/
  return reg.test(name)
}

export function validateProjectName(name) {
  const reg = /^[A-z0-9_-]{1,50}$/
  return reg.test(name)
}

export function validateOpenShiftAppName(name) {
  // Comment translated to English.
  const reg = /^[A-Za-z]{1}[A-z0-9_-]{1,16}[A-Za-z0-9]$/
  return reg.test(name)
}



/* Comment translated to English. */
export function maxLengthCheck(title, maxLength){  
  maxLength = maxLength || 255;
  if(Number(byteCheck(title)) > Number(maxLength)) {
      return false;
  } else {
      return true;
 }
}

/* Comment translated to English. */
export function byteCheck(txt){
 let codeByte = 0;
 for (let idx = 0; idx < txt.length; idx++) {
     let oneChar = escape(txt.charAt(idx));
     if ( oneChar.length == 1 ) {
         codeByte ++;
     } else if (oneChar.indexOf("%u") != -1) {
         codeByte += 2;
     } else if (oneChar.indexOf("%") != -1) {
         codeByte ++;
     }
 }
 return codeByte;
}


export function getSize(fileSize, fixed) {
  var value = {}
  // Comment translated to English.
  if (fileSize >= 1024 * 1024 * 1024) {
    fileSize = fileSize / (1024 * 1024 * 1024)
    fileSize = (fixed === undefined) ? fileSize : fileSize.toFixed(fixed)
    value.size = fileSize
    value.unit = 'gb'
  }

  // Comment translated to English.
  if (fileSize >= 1024 * 1024) {
    fileSize = fileSize / (1024 * 1024)
    fileSize = (fixed === undefined) ? fileSize : fileSize.toFixed(fixed)
    value.size = fileSize
    value.unit = 'mb'
  } else if (fileSize >= 1024) { // Comment translated to English.
    fileSize = fileSize / 1024
    fileSize = (fixed === undefined) ? fileSize : fileSize.toFixed(fixed)
    value.size = fileSize
    value.unit = 'kb'
  } else { // Comment translated to English.
    fileSize = (fixed === undefined) ? fileSize : fileSize.toFixed(fixed)
    value.size = fileSize
    value.unit = 'byte'
  }
  return value
}

export function isOverOneDay(curDate) {
  var today, resultDate
  today = new Date()
  resultDate = new Date(curDate)

  // Time (minutes * seconds * millisecond)
  if ((today - resultDate) / (60 * 60 * 1000) <= 24) {
    return true
  }
  return false
}

export function toPascalCase(str) {
  var arr = str.split(/\s|_/)
  for (var i = 0, l = arr.length; i < l; i++) {
    arr[i] = arr[i].substr(0, 1).toUpperCase() +
                 (arr[i].length > 1 ? arr[i].substr(1).toLowerCase() : '')
  }
  return arr.join(' ')
}

export function copyClipboard(str) {
  var tempElem = document.createElement('textarea')
  tempElem.value = str
  document.body.appendChild(tempElem)

  tempElem.select()
  document.execCommand('copy')
  document.body.removeChild(tempElem)
}


/* Comment translated to English. */
export function arrayToObject(ary) {
	let object = {};
	if (ary == null)
		return {};
	
	ary.forEach((item) => {
		object[item.key] = item.value;
	})

	return object;
}

/* Comment translated to English. */
export function valueObjectToArray(ary) {
	let array = [];
	if (ary == null)
		return [];
	
	
	ary.forEach((item) => {
		array.push(item.value);
	})

	return array;
}


/* Comment translated to English. */
export function objectToArray(obj) {
	let toArray = [];
	if (obj == null)
		return [];
		
	Object.keys(obj).forEach((key) => {
		toArray.push({
			key: key,
			value:obj[key]
		})	
	})

	return toArray;
}

/*
["value1", "value2"] => [{value:"value1"}, {value:"value2"}]
*/
export function arrayToValueObjectArray(targetArray) {
	let toArray = [];

	if (targetArray == null)
		return [{value:""}];
	
	targetArray.forEach((value) => {
		toArray.push({
			value:value
		})
	})

	return toArray;
}



export function isEmptyObject(obj) {
	if (obj == null)
		return true;
	
	
	if (Object.keys(obj).length == 0) {
		return true;
	}

	return false;
}


/* Comment translated to English. */
export function splitACRServerInfo(str) {
	let index = str.indexOf(".");
	let info = {
		name:"",
		domain:""
	}
	if (index == -1) {
		info.name = str;	
	} else {
		info.name = str.substr(0, index);
		info.domain = str.substr(index+1, str.length);
	}

	return info;		
}
export function joinACRServerInfo(name, domain) {
	return name +"."+domain;
}